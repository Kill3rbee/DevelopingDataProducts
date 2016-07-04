### vFeed - The Correlated Vulnerability And Threat Database

This Shiny App is for searching and visualizing vFeed fully aggregated, cross-linked and standardized Vulnerability Database based on CVE and other standards (CPE, CWE, CAPEC, OVAL, CVSS). 

### Introduction
Remediation is a requirement for vulnerability findings, which makes determining what to remediate, and when, difficult to prioritize.  What exactly should be remediated is application specific and must be determined by the business risks associated with the application in conjunction with the security requirements.   This tool outlines a standard procedure for selecting findings that should be remediated immediately given the impact and exploitability.


### Background
I have always wanted to use data to prioritize remediation efforts based on exploits in the wild and their impact on the organization. Many organizations are faced with similar challenges, which are being compounded by the new kid on the block 
<span style="color:red">**`DevOPs`**</span>. 

This class provided me with the opportunity to address two questions. 
- <span style="color:red">**`What is the problem really?`**</span> 
- <span style="color:red">**`Do we really want to solve it?`**</span>.

### CVSS
There are six metrics <span style="color:red">**`Access Vector`**</span>, <span style="color:red">**`Access Complexity`**</span>, <span style="color:red">**`Authentication`**</span>, <span style="color:red">**`Confidentiality`**</span>, <span style="color:red">**`Integrity`**</span>, <span style="color:red">**`Availability`**</span> used to calculate the exploitability and impact sub-scores of the vulnerability. These sub-scores are used to calculate the overall base score. Please visit <a href="https://www.first.org/cvss/v2/guide/" target="_blank">CVSS v2.0</a> or 
<a href="https://en.wikipedia.org/wiki/CVSS" target="_blank">Wikipedia</a> for more information.

<img src="exploit.svg"  height="60%" width="60%"/> 

<img src="impact.svg"  height="70%" width="70%"/>

<img src="fimpact.svg"  height="25%" width="25%"/>

<img src="base.svg"  height="80%" width="80%"/>

The U.S. government National Vulnerability Database together with NIST created The Common Vulnerability Scoring System (CVSS) that provides an open framework for communicating the characteristics and impacts of IT vulnerabilities. 

### Data Source
The data set is from <a href="https://github.com/toolswatch/vFeed/wiki" target="_blank">Toolswatch.org Github</a> that contains detective and preventive security information repository used for gathering vulnerability and mitigation data from different source on the internet.

### How To
- <span style="color:red">**`Click to Load CWE Titles`**</span> this shiny does not load data right away. Continue to navigate site CWE Titles are being loaded.
- <span style="color:red">**`Dashboard`**</span> to see six metrics used to calculate the exploitability and impact sub-scores of the vulnerability for selected years and risk score. 
- <span style="color:red">**`Click to View CVE Category`**</span> to see General CVEs and Web Application related CVEs.
- <span style="color:red">**`Selections`**</span> You can clear all titles and select only those you want to view.
