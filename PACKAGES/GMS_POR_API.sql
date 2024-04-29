--------------------------------------------------------
--  DDL for Package GMS_POR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_POR_API" AUTHID CURRENT_USER as
--$Header: gmspor1s.pls 120.0 2005/05/29 11:24:55 appldev noship $

	FUNCTION get_award_number ( X_award_set_id  		IN NUMBER,
				    X_award_id			IN NUMBER,
				    X_req_distribution_id 	IN NUMBER)
	return VARCHAR2 ;

	FUNCTION get_award_ID ( X_award_set_id  	IN NUMBER,
			    	X_award_number		IN VARCHAR2,
			    	X_req_distribution_id 	IN NUMBER)
	return NUMBER ;

	PROCEDURE validate_award ( X_project_id		IN NUMBER,
				   X_task_id		IN NUMBER,
				   X_award_id		IN NUMBER,
				   X_award_number	IN VARCHAR2,
				   X_expenditure_type	IN VARCHAR2,
				   X_expenditure_item_date IN DATE,
				   X_calling_module	IN VARCHAR2,
                                   X_source_type_code   IN VARCHAR2,
				   X_status		IN OUT NOCOPY VARCHAR2,
				   X_err_msg		OUT NOCOPY VARCHAR2 ) ;
        --BUG 3295360 : add Procedure to provide  backward compatibility through overloading
	PROCEDURE validate_award ( X_project_id		IN NUMBER,
				   X_task_id		IN NUMBER,
				   X_award_id		IN NUMBER,
				   X_award_number	IN VARCHAR2,
				   X_expenditure_type	IN VARCHAR2,
				   X_expenditure_item_date IN DATE,
				   X_calling_module	IN VARCHAR2,
				   X_status		IN OUT NOCOPY VARCHAR2,
				   X_err_msg		OUT NOCOPY VARCHAR2 ) ;

	PROCEDURE account_generator_ADL ( X_project_id		IN NUMBER,
					  X_task_id		IN NUMBER,
					  X_award_id		IN NUMBER,
					  X_event		IN VARCHAR2,
					  X_award_set_id	IN OUT NOCOPY NUMBER,
					  X_status		IN OUT NOCOPY varchar2 ) ;

	PROCEDURE when_insert_line (	X_distribution_id	IN NUMBER,
					X_project_id		IN NUMBER,
				   	X_task_id		IN NUMBER,
				   	X_award_id		IN NUMBER,
				   	X_expenditure_type	IN VARCHAR2,
				   	X_expenditure_item_date IN DATE,
					X_award_set_id		OUT NOCOPY NUMBER,
					X_status		IN OUT NOCOPY varchar2 ) ;
        --
	-- 3068454 ( CHANGE REQUIRED IN GMS_POR_API.WHEN_UPDATE/INSERT_LINE TO WORK
	-- WITH OA GUIDELINE )
	--
        PROCEDURE get_req_dist_AwardSetID ( X_distribution_id   IN NUMBER,
					    X_award_set_id      OUT NOCOPY NUMBER,
					    X_status            IN OUT NOCOPY varchar2 ) ;

	PROCEDURE when_update_line (	X_distribution_id	IN NUMBER,
					X_project_id		IN NUMBER,
				   	X_task_id		IN NUMBER,
				   	X_award_id		IN NUMBER,
				   	X_expenditure_type	IN VARCHAR2,
				   	X_expenditure_item_date IN DATE,
					X_award_set_id          OUT NOCOPY NUMBER,
					X_status		IN OUT NOCOPY varchar2 ) ;

	PROCEDURE when_update_line (	X_distribution_id	IN NUMBER,
					X_project_id		IN NUMBER,
				   	X_task_id		IN NUMBER,
				   	X_award_id		IN NUMBER,
				   	X_expenditure_type	IN VARCHAR2,
				   	X_expenditure_item_date IN DATE,
					X_status		IN OUT NOCOPY varchar2 ) ;

	PROCEDURE when_delete_line (	X_distribution_id	IN NUMBER,
					X_status		IN OUT NOCOPY varchar2 ) ;

       --
       -- Start : 3103564
       --         NEW DELETE API NEEDED FOR DELETING AN AWARD DISTRIBUTION LINE
       --
       -- Start of comments
       --	API name 	: delete_adl
       --	Type		: Public
       --	Pre-reqs	: None.
       --	Function	: Deletes a record from gms_award_distributions
       --			  table.
       --	Parameters	:
       --	IN		: p_award_set_id          IN NUMBER	Required
       --			  .
       --			  .
       --       OUT             : x_status               OUT Varchar2
       --                         values are 'S', 'E', 'U'
       --                         fnd_api.G_RET_STS_SUCCESS
       --                         fnd_api.G_RET_STS_ERROR
       --                         fnd_api.G_RET_STS_UNEXP_ERROR
       -- End of comments

       PROCEDURE delete_adl ( p_award_set_id 	IN NUMBER,
                              x_status          OUT NOCOPY varchar2,
                              x_err_msg         OUT NOCOPY varchar2 ) ;
       --
       -- NEW DELETE API NEEDED FOR DELETING AN AWARD DISTRIBUTION LINE
       -- End : 3103564
       --

        --=================================================================
        -- Bug-2557041
        -- This API used by IP to determine award distribution information
        --=================================================================
        PROCEDURE get_award_dist_param (p_award_dist_option     OUT NOCOPY VARCHAR2,
                                        p_dist_award_number     OUT NOCOPY VARCHAR2,
                                        p_dist_award_id         OUT NOCOPY NUMBER );

        --==============================================================
        --Bug-2557041
        -- following API used to validate dummy award specific validation
        --==============================================================
        PROCEDURE validate_dist_award(  p_project_id            IN NUMBER,
                                        p_task_id               IN NUMBER,
                                        p_award_id              IN NUMBER,
                                        p_expenditure_type      IN VARCHAR2,
                                        p_status                IN OUT NOCOPY VARCHAR2,
                                        p_err_msg_label         OUT NOCOPY VARCHAR2 ) ;

        --=============================================================
        -- Bug-2557041
        -- The purpose of this API is to prepare for award distributions
        -- and kicks off award distribution engine
        --=============================================================
        PROCEDURE distribute_award ( p_doc_header_id               IN NUMBER,
                                     p_distribution_id             IN NUMBER,
                                     p_document_source             IN VARCHAR2,
                                     p_gl_encumbered_date          IN DATE,
                                     p_project_id                  IN NUMBER,
                                     p_task_id                     IN NUMBER,
                                     p_dummy_award_id              IN NUMBER,
                                     p_expenditure_type            IN VARCHAR2,
                                     p_expenditure_organization_id IN NUMBER,
                                     p_expenditure_item_date       IN DATE,
                                     p_quantity                    IN NUMBER,
                                     p_unit_price                  IN NUMBER,
                                     p_func_amount                 IN NUMBER,
                                     p_vendor_id                   IN NUMBER,
                                     p_source_type_code            IN VARCHAR2,
                                     p_award_qty_obj               OUT NOCOPY gms_obj_award,
                                     p_status                      OUT NOCOPY VARCHAR2,
                                     p_error_msg_label             OUT NOCOPY VARCHAR2 );


	FUNCTION enabled return varchar2 ;



END GMS_POR_API ;

 

/
