<div style="background-color: #273c75; color: #ffffff; padding: 20px; border-radius: 10px;">

# **Calculations & Important Concepts**

---

## **<span style="color: #CCCCCC;">Health Factor</span>**

$$\text{Health Factor = }\frac{\text{Current Value of Collateral}}{\text{Total Debt Owned} \times \text{Liquidation Threshold}}$$

Where:

- **Current Value of Collateral**: The market value of the assets used as collateral.
- **Total Debt Owed**: The sum of the borrowed amount and any accrued interest or fees.
- **Liquidation Threshold**: The ratio at which the loan is considered for liquidation.

The **Health Factor** represents the health or safety of the loan. A Health Factor greater than 1 implies a lower risk of liquidation.

---

## **<span style="color: #CCCCCC;">Loan-to-Value(LTV) Ratio</span>** 


$$\text{Loan-to-value Ratio = }\frac{\text{Borrowed Amount}}{\text{Current Value of Collateral} \times \text{Minimum Collateral Ratio}}$$

Where:

- **Borrowed Amount**: The total amount of money borrowed, including any accrued interest or fees.
- **Current Value of Collateral**: The market value of the assets used as collateral.
- **Minimum Collateral Ratio (MCR)**: The minimum required collateral ratio specified by the lending platform.

The **LTV ratio** represents the proportion of the borrowed amount in relation to the value of the collateral. A higher LTV ratio indicates a higher risk for the lender because it means the loan is less collateralized.

---

## **<span style="color: #CCCCCC;">Maximum Loan-to-Value(LTV)</span>** 


$$\text{Maximum Loan-to-value = }\frac{\text{1}}{\text{Minimum Collateral Ratio}}$$

Where:
- **Minimum Collateral Ratio (MCR)**: The minimum required collateral ratio specified by the lending platform.

The **Maximum LTV** is the maximum loanable amount for the collateral given.

---

## **<span style="color: #CCCCCC;">Minimum Collateral Ratio (MCR)</span>** 

The minimum collateral ratio requirement to be eligible for a loan. This is a safety measure to ensure that loans are overcollateralized, reducing the risk of loss for the lender. A ratio of 1.5 means that the collateral must be worth at least 150% of the loan value. If it falls below 150% the loan becomes eligible for liquidation or if a separate liquidation threshold is set then it will be liquidated at that threshold.

---

## **<span style="color: #CCCCCC;">Liquidation Threshold</span>** 

The threshold for liquidation expressed as a ratio; if the collateral ratio falls below this threshold. It's usually the same ratio as MCR or lower.

---

<br>
<br>
<br>
<br>

---

# **Protocol Parameters**

##### This refers to the configurable variables and settings that govern the protocol’s behavior, including collateralization ratios, liquidation thresholds, loan terms, reserve ratios, etc. These parameters are essential for defining the protocol’s rules and risk management. The following parameters are essential for our model:
---

- *<span style="color: #CCCCCC;">Minimum Eligible Health Factor </span>* the minimum health factor allowed to avail loan.
---
- *<span style="color: #CCCCCC;">Minimum Collateral Ratio (MCR) - ADA: </span>* This parameter specifies the minimum ratio of collateral (in ADA cryptocurrency) required relative to the loan amount to maintain the loan. If the collateral value falls below this ratio (unless there's a lower liquidation threshold) due to market fluctuations, the loan may become subject to liquidation to protect the lender from default risk.
---
- *<span style="color: #CCCCCC;">Minimum Collateral Ratio (MCR) - Utility Token: </span>* Similar to the MCR for ADA, this parameter defines the minimum ratio of collateral required in a specific utility token relative to the loan amount. This ensures that loans backed by utility tokens maintain a sufficient collateral buffer to account for market volatility.
---
- *<span style="color: #CCCCCC;">Minimum Loan Amount: </span>*: The minimum loan amount sets the lowest value of funds that can be borrowed through the protocol. This parameter ensures that loans are economically viable, taking into account the operational costs and the effort required to manage and monitor loans.
---
- *<span style="color: #CCCCCC;">Maximum Loan Term: </span>*: This parameter defines the maximum duration for which a loan can be extended. It helps in managing the risk associated with long-term loans and ensures that loans are repaid within a reasonable timeframe, minimizing the exposure to prolonged market risks.
---
- *<span style="color: #CCCCCC;">Protocol Usage Fee: </span>*: The Protocol Usage Fee is a fixed charge applied each time a loan is created or repaid within the protocol. This fee is designed to cover the costs associated with the loan's administration and the provision of the protocol's services.
---
- *<span style="color: #CCCCCC;">Liquidation Penalty Fee: </span>*: The liquidation penalty is a fee imposed on the collateral if the loan is liquidated due to a breach of the loan terms, such as falling below the minimum collateral ratio. This penalty acts as a deterrent against risky borrowing behavior and compensates the lender for the additional risk and effort involved in liquidating the collateral.
---
- *<span style="color: #CCCCCC;">Reserve Threshold: </span>*: TBD
---
- *<span style="color: #CCCCCC;">Reserve Ratio: </span>*: TBD
</div>