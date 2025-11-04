# **Operational Research Project: NewSatellites S.p.A.**

This repository contains the MATLAB implementation for a supply chain design project. As consultants for **NewSatellites S.p.A.**, a satellite production and launch company, we have been tasked with designing a new supply chain by deciding where to locate component production centers and assembly centers.

## **1\. Problem Description**

The objective is to meet the forecasted annual demand for different types of satellites at the minimum total cost.

### **Assembly Centers**

* Assembly centers are highly automated and can be one of three sizes: **small, medium, or large**.  
* As the size of the center increases, assembly costs decrease, while opening costs and the maximum number of satellites that can be assembled increase.  
* Launch costs are independent of the plant's size.  
* Data is provided in assembly-plant\_cost.csv.

### **Production Centers**

* Component production centers are specialized in a given subset of components.  
* Opening costs are in prod\_plant.csv.  
* Production costs, production limits, and the list of producible components are described in prod\_plant\_cost.csv.

### **Logistics and Costs**

* A set of potential locations is known for both types of centers.  
* Transportation costs between potential production and assembly sites are known (file transportation.costs.csv).  
* Each satellite type is composed of different components, described in the gozinto.csv file (a "bill of materials" matrix).  
* The company estimates an annual demand for the different satellite types, described in sales\_forecast.csv.

### **Key Constraints**

1. **Demand:** The company's objective is to satisfy the forecasted demand.  
2. **Redundancy:** To ensure constant component production, the company wants at least **two different production plants** producing the same component.

## **2\. Project Tasks**

This project answers the following questions:

1. **Formulation and Implementation:** Formulate the problem as a mathematical model and implement a script in **MATLAB** to solve it.  
2. **Demand Sensitivity:** Discuss how the optimal supply chain changes as the estimated annual satellite demand varies.  
3. **Cost Sensitivity:** By fixing the variables that describe the location and size of the plants, observe how the cost to meet demand varies with actual satellite sales. (This involves generating various demand scenarios).

## **3\. Data Files**

The model is defined by the following data files:

* **assembly\_plant\_cost.csv**: For each potential assembly location:  
  * installation\_costs\_\<size\>  
  * assembly\_costs\_\<size\>  
  * max\_prod\_\<size\>  
  * launch\_cost  
* **prod\_plant.csv**: For each potential production location:  
  * cost (opening cost)  
* **prod\_plant\_cost.csv**: For each potential production location:  
  * component (a component it can produce)  
  * production\_cost  
  * limit (production limit)  
* **transportation.costs.csv**: A matrix $c\_{ij}$ representing the transport cost from production center $i$ to assembly center $j$.  
* **gozinto.csv**: A matrix $g\_{ij}$ representing the number of components $j$ required for each satellite $i$.  
* **sales\_forecast.csv**: A vector $v\_{i}$ representing the sales forecast for each satellite $i$.

## **4\. Deliverables**

* A **PDF report** presenting the solution to the questions above.  
* A MATLAB file named **solution\_problem\_\<id\_matricola\>.m** containing a function named **solve\_problem\_\<id\_matricola\>** that solves the model. This function takes a folder\_name argument which identifies the directory containing all the .csv files.

