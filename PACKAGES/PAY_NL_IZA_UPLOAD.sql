--------------------------------------------------------
--  DDL for Package PAY_NL_IZA_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_IZA_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: pynlizau.pkh 120.0 2005/05/29 06:55:53 appldev noship $ */
level_cnt NUMBER;

c_default_action_if_exists   CONSTANT VARCHAR2 (1)  := 'R';



/*--------------------------------------------------------------------
|Name       : iza_upload              	                             |
|Type	    : Procedure				                     |
|Description: This Procedure initiates the IZA upload process. It    |
|	      takes in the parameters passed from the information in |
|	      concurrent program definition and calls various        |
|	      procedures for inserting data into pay_batch_headers   |
|             and pay_batch_lines table.                             |
----------------------------------------------------------------------*/


PROCEDURE iza_upload(	errbuf                     OUT NOCOPY   VARCHAR2,
			retcode                    OUT NOCOPY   NUMBER,
			p_file_name                IN       VARCHAR2,
			p_batch_name               IN       VARCHAR2,
			p_effective_date           IN       VARCHAR2,
			p_business_group_id        IN       per_business_groups.business_group_id%TYPE,
			p_action_if_exists         IN       VARCHAR2 DEFAULT NULL,
			p_dummy_action_if_exists   IN	    VARCHAR2 DEFAULT NULL,
			p_date_effective_changes   IN       VARCHAR2 DEFAULT NULL
		      ) ;


/*-----------------------------------------------------------------------
|Name       : iza_validation                                            |
|Type	    : Procedure				                        |
|Description: Procedure to validate the Data Record. This procedure     |
|	      decides if the record needs to be processed or rejected   |
|	      If the record needs to rejected, this Procedure           |
|	      sets the value of the OUT parameter p_reject_reason_code  |
|             equalt to the reject reason code as given in the          |
|             NL_IZA_REJECT_REASON lookup. Else the p_reject_reason_code|
|             is set to '00'                                            |
-----------------------------------------------------------------------*/

PROCEDURE iza_validation(p_business_group_id	IN NUMBER
		        ,p_period_start_date 	IN DATE
		        ,p_period_end_date 	IN DATE
		        ,p_exchange_number 	IN VARCHAR2
		        ,p_client_num		IN VARCHAR2
		        ,p_sub_emplr_num	IN VARCHAR2
			,p_org_id		IN NUMBER
			,p_org_struct_version_id IN NUMBER
		        ,p_person_id		OUT NOCOPY NUMBER
		        ,p_assignment_id	OUT NOCOPY NUMBER
		        ,p_assignment_num	OUT NOCOPY VARCHAR2
		        ,p_reject_reason_code	OUT NOCOPY VARCHAR2) ;



/*--------------------------------------------------------------------
|Name       : val_create_batch_line              	             |
|Type	    : Procedure				                     |
|Description: This procedure will take in the Data Record, validates |
|	      it and decides if it needs to be processed or rejected |
|	      by calling the function iza_validation.                |
|	      After validation it calls the wrapper procedure        |
|             create_batch_line to create a record in pay_batch_lines|
|             It also creates the record in the table                |
|             PAY_NL_IZA_UPLD_STATUS table for Rejected and Processed|
|             records.                                               |
----------------------------------------------------------------------*/

Procedure val_create_batch_line( p_line_read IN VARCHAR2
		    		,p_batch_id IN NUMBER
		    		,p_batch_seq IN NUMBER
		    		,p_process_yr_mm IN VARCHAR2
		    		,p_payroll_center IN VARCHAR2
		    		,p_org_id IN NUMBER
		    		,p_org_struct_version_id IN NUMBER
		    		,p_bg_id IN NUMBER
		    		,p_eff_date IN DATE
		    		,p_batch_line_id OUT NOCOPY NUMBER
		    		,p_bl_ovn OUT NOCOPY NUMBER);


/*--------------------------------------------------------------------
|Name       : create_batch_header              	                     |
|Type	    : Procedure				                     |
|Description: This procedure is a wrapper over the core              |
|             create_batch_header procedure defined in               |
|             PAY_BATCH_ELEMENT_ENTRY_API                            |
----------------------------------------------------------------------*/


PROCEDURE create_batch_header (p_effective_date           IN       	DATE
			      ,p_name                     IN       	VARCHAR2
			      ,p_bg_id                    IN       	NUMBER
			      ,p_action_if_exists         IN       	VARCHAR2 DEFAULT c_default_action_if_exists
			      ,p_date_effective_changes   IN		VARCHAR2 DEFAULT NULL
			      ,p_batch_id                 OUT NOCOPY  	NUMBER
			      ,p_ovn                      OUT NOCOPY  	NUMBER
			      );



/*--------------------------------------------------------------------
|Name       : create_batch_line              	                     |
|Type	    : Procedure				                     |
|Description: This procedure is a wrapper over the core              |
|	      create_batch_line procedure defined in                 |
|	      PAY_BATCH_ELEMENT_ENTRY_API                            |
----------------------------------------------------------------------*/


PROCEDURE create_batch_line (p_session_date                  DATE
			    ,p_batch_id                      pay_batch_lines.batch_id%TYPE
			    ,p_assignment_id                 pay_batch_lines.assignment_id%TYPE
			    ,p_assignment_number             pay_batch_lines.assignment_number%TYPE
			    ,p_batch_sequence                pay_batch_lines.batch_sequence%TYPE
			    ,p_effective_date                pay_batch_lines.effective_date%TYPE
			    ,p_date_earned                   pay_batch_lines.date_earned%TYPE
			    ,p_element_name                  pay_batch_lines.element_name%TYPE
			    ,p_element_type_id               pay_batch_lines.element_type_id%TYPE
			    ,p_value_1                       pay_batch_lines.value_1%TYPE
			    ,p_bline_id     		     OUT NOCOPY  NUMBER
			    ,p_obj_vn			     OUT NOCOPY  NUMBER
			    );



/*-----------------------------------------------------------------------
|Name       : purge_iza_process_status              	                |
|Type	    : Procedure				                        |
|Description: Driving Procedure for the concurrent program for          |
|             IZA Upload Purge Process. This Procedure will purge all   |
|             the records from the Process Status table that are no     |
|             longer required                                           |
-----------------------------------------------------------------------*/


procedure purge_iza_process_status (p_errbuf            OUT     NOCOPY  VARCHAR2
				   ,p_retcode		OUT     NOCOPY  VARCHAR2
				   ,p_business_group_id IN      NUMBER
				   ,p_month_from 	IN      VARCHAR2
				   ,p_month_to	    	IN      VARCHAR2
				   ,p_org_struct_id	IN	NUMBER
				   ,p_employer_id	IN      NUMBER
				   ) ;

END PAY_NL_IZA_UPLOAD;



 

/
