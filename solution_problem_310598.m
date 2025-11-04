function value = solve_problem_310598(folder_name)
    numAssemblyPlant_dimensions = 3;
    minProdComp = 2;

    %% DATABASE
    assembly_plant_costs = readtable(folder_name + "/assembly_plant_cost.csv");
    numAssemblyPlant = size(assembly_plant_costs.locations, 1);
    %assemblyPlant_installCosts ha sulle righe le locations per i CA, sulle
    %colonne i prezzi di installazione per dimensione
    assemblyPlant_installCosts = zeros(numAssemblyPlant, numAssemblyPlant_dimensions);
    assemblyPlant_installCosts(:,1) = assembly_plant_costs.installation_costs_small;
    assemblyPlant_installCosts(:,2) = assembly_plant_costs.installation_costs_medium;
    assemblyPlant_installCosts(:,3) = assembly_plant_costs.installation_costs_big;
    %assembly_launch_cost contiene i di lancio fissi
    satelliteLaunchCosts = assembly_plant_costs.launch_cost;
    %assemblyPlant_prodCosts contiene i prezzi di produzione in un CA in base
    %alla dimensione del CA
    assemblyPlant_prodCosts = zeros(numAssemblyPlant, numAssemblyPlant_dimensions);
    assemblyPlant_prodCosts(:,1) = assembly_plant_costs.assembly_cost_small;
    assemblyPlant_prodCosts(:,2) = assembly_plant_costs.assembly_cost_medium;
    assemblyPlant_prodCosts(:,3) = assembly_plant_costs.assembly_cost_big;
    %assemblyPlant_maxProd contiene il max di prod in un centro di una certa
    %dimensione
    assemblyPlant_maxProd = zeros(numAssemblyPlant, numAssemblyPlant_dimensions);
    assemblyPlant_maxProd(:,1) = assembly_plant_costs.max_prod_small;
    assemblyPlant_maxProd(:,2) = assembly_plant_costs.max_prod_medium;
    assemblyPlant_maxProd(:,3) = assembly_plant_costs.max_prod_big;
    
    %gozinto contiene per ogni tipo di satellite (sulle colonne) quanto di un
    %certo componente (sulle colonne) serve
    gozInto = readmatrix(folder_name + "/gozinto.csv");
    [num_satellites, num_components] = size(gozInto);
    
    %prodPlant_openCost contiente per ogni CP il costo costo di apertura fisso (è un 
    %vettore, no matrice)
    prodPlant_openCost = readmatrix(folder_name + "/prod_plant.csv", "Range","B2:B51");
    numProdPlant = size(prodPlant_openCost, 1);
    
    %prodPlant_maxProd contiene il numero massimo di componente (colonne)
    %di un certo tipo producibili nel CP sulla riga
    prodPlant_maxProd = zeros(numProdPlant, num_components);
    %prodPlant_compCost contiene il costo di produzione di componente (colonne)
    %in un certo centro di produzione (righe)
    prodPlant_compCost = zeros(numProdPlant, num_components);
    %prdPlant_compProdinPC = 1 se nel centro di produzione (riga) viene
    %prodotto il componente (colonna)
    prodPlant_compProdinPC = zeros(numProdPlant, num_components);
    prod_plant_cost = readtable(folder_name + "/prod_plant_cost.csv");
    for j = 1:size(prod_plant_cost.locations, 1)
        for i = 0:(numProdPlant-1)
            if "L"+i == prod_plant_cost.locations(j)
                prodPlant_maxProd(i+1, prod_plant_cost.component(j, 1)+1) = prod_plant_cost.limit(j, 1);
                prodPlant_compCost(i+1, prod_plant_cost.component(j, 1)+1) = prod_plant_cost.production_cost(j,1);
                prodPlant_compProdinPC(i+1, prod_plant_cost.component(j,1)+1) = 1;
            end
        end
    end
    
    %sales_forecast associa a ogni satellite la domanda prevista (deterministico)
    sales_forecast = readmatrix(folder_name + "/sales_forecast.csv");
    sales_forecast = rmmissing(sales_forecast');
    
    %transportation_costs associa alla tratta CP (righe) - CA (colonne) il
    %prezzo di trasporto unitario
    transportation_costs = readmatrix(folder_name + "/transportation_costs.csv");
    
    %% PROBLEM SETUP
    prob = optimproblem("ObjectiveSense","min");
    
    % variabili decisionali
    makeTypeSatellite = optimvar('makeTypeSatellite', numAssemblyPlant, num_satellites, 'Type','integer', 'LowerBound',0);
    makeDimSatellite = optimvar('makeDimSatellite', numAssemblyPlant, numAssemblyPlant_dimensions, 'Type','integer', 'LowerBound',0,'UpperBound',assemblyPlant_maxProd);
    deltaMakeDimSatellite = optimvar('deltaMakeDimSatellite', numAssemblyPlant, numAssemblyPlant_dimensions, 'Type','integer','LowerBound',0,'UpperBound',1);
    
    makeComponent = optimvar('makeComponent', numProdPlant, num_components, 'Type','integer','LowerBound',0, 'UpperBound',prodPlant_maxProd);
    deltaProdPlantOpen = optimvar('deltaProdPlantOpen', numProdPlant, 1,'Type','integer', 'LowerBound',0,'UpperBound',1);
    deltaProdPlantCompLineOpen = optimvar('deltaProdPlantCompLineOpen', numProdPlant, num_components, 'Type','integer','LowerBound',0,'UpperBound',prodPlant_compProdinPC);
    
    totFLux = optimvar('totFlux', numProdPlant, numAssemblyPlant, num_components, 'Type','continuous','LowerBound',0);
    
    componentsNeedInAssemblyPlant = makeTypeSatellite*gozInto;
    totSatelliteMade = sum(makeTypeSatellite);
    totSatelliteMadePerAssemblyPlant = sum(makeTypeSatellite, 2);
    
    % funzione obiettivo
    prob.Objective = sum(sum(totFLux,3).*transportation_costs, 'all') + sum(assemblyPlant_installCosts.*deltaMakeDimSatellite, 'all') + ...
        sum(assemblyPlant_prodCosts.*makeDimSatellite, 'all') + sum(prodPlant_compCost.*makeComponent,'all') + dot(prodPlant_openCost, deltaProdPlantOpen) +...
        dot(satelliteLaunchCosts, totSatelliteMadePerAssemblyPlant);
    
    % vincoli
    prob.Constraints.onlyOneDimAssemblyPlant = sum(deltaMakeDimSatellite, 2) <= 1;
    prob.Constraints.makeTypeSat_Equal_makeDimSat = sum(makeTypeSatellite, 2) == sum(makeDimSatellite, 2);
    prob.Constraints.demandSatisfactions = totSatelliteMade >= sales_forecast;
    prob.Constraints.makeDimSatBigM = makeDimSatellite <= assemblyPlant_maxProd.*deltaMakeDimSatellite;
    prob.Constraints.consistencyConstraint = sum(deltaProdPlantCompLineOpen) >= minProdComp;
    prob.Constraints.prodPlant_compLineOpenBigM = makeComponent <= deltaProdPlantCompLineOpen.*prodPlant_maxProd;
    
    fluxIntake = optimconstr(numAssemblyPlant,num_components);
    for i = 1:num_components
        fluxIntake(:,i) = sum(totFLux(:,:,i)) == componentsNeedInAssemblyPlant(:,i)';
    end
    prob.Constraints.fluxIntake = fluxIntake;
    
    fluxEmission = optimconstr(numProdPlant,num_components);
    for i = 1:num_components
        fluxEmission(:,i) = sum(totFLux(:,:,i), 2) <= makeComponent(:,i);
    end
    prob.Constraints.fluxEmission = fluxEmission;
    
    ifProdPlantClosed_AllProdLinesClosed = optimconstr(numProdPlant,num_components);
    for i = 1:num_components
        ifProdPlantClosed_AllProdLinesClosed(:,i) = deltaProdPlantCompLineOpen(:,i) <= deltaProdPlantOpen;
    end
    prob.Constraints.ifProdPlantClosed_AllProdLinesClosed = ifProdPlantClosed_AllProdLinesClosed;
    
    %% SOLVE PROBLEM
    %show(prob);
    [sol, value] = solve(prob);
    format bank
    display(value);
end