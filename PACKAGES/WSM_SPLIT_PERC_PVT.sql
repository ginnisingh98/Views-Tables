--------------------------------------------------------
--  DDL for Package WSM_SPLIT_PERC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_SPLIT_PERC_PVT" AUTHID CURRENT_USER AS
/* $Header: WSMCOSPS.pls 115.1 2003/12/17 18:55:34 sthangad noship $ */

 /*---------------------------------------------------------------------------+
 | Procedure to insert a row in the split percentages table for a given	      |
 | (co-product,co product group, effective date, disable date) 		      |
 +---------------------------------------------------------------------------*/

PROCEDURE insert_row(x_err_code 		OUT NOCOPY NUMBER,
   	    	     x_err_msg                  OUT NOCOPY VARCHAR2,
		     p_co_product_id  		IN NUMBER,
		     p_co_product_group_id	IN NUMBER,
		     p_organization_id		IN NUMBER,
		     p_revision			IN VARCHAR2,
		     p_split			IN NUMBER,
		     p_primary_flag		IN VARCHAR2,
		     p_effectivity_date		IN DATE,
		     p_disable_date		IN DATE,
		     p_creation_date		IN DATE,
		     p_created_by 		IN NUMBER,
		     p_last_update_date		IN DATE,
		     p_last_updated_by 		IN NUMBER,
		     p_last_update_login	IN NUMBER     DEFAULT NULL,
		     p_attribute_category	IN VARCHAR2   DEFAULT NULL,
		     p_attribute1		IN VARCHAR2   DEFAULT NULL,
		     p_attribute2		IN VARCHAR2   DEFAULT NULL,
		     p_attribute3		IN VARCHAR2   DEFAULT NULL,
		     p_attribute4		IN VARCHAR2   DEFAULT NULL,
		     p_attribute5		IN VARCHAR2   DEFAULT NULL,
		     p_attribute6		IN VARCHAR2   DEFAULT NULL,
		     p_attribute7		IN VARCHAR2   DEFAULT NULL,
		     p_attribute8		IN VARCHAR2   DEFAULT NULL,
		     p_attribute9		IN VARCHAR2   DEFAULT NULL,
		     p_attribute10		IN VARCHAR2   DEFAULT NULL,
		     p_attribute11		IN VARCHAR2   DEFAULT NULL,
		     p_attribute12		IN VARCHAR2   DEFAULT NULL,
		     p_attribute13		IN VARCHAR2   DEFAULT NULL,
		     p_attribute14		IN VARCHAR2   DEFAULT NULL,
		     p_attribute15		IN VARCHAR2   DEFAULT NULL,
		     p_request_id               IN NUMBER     DEFAULT NULL,
                     p_program_application_id   IN NUMBER     DEFAULT NULL,
                     p_program_id               IN NUMBER     DEFAULT NULL,
                     p_program_update_date      IN DATE       DEFAULT NULL
		     );

 /*---------------------------------------------------------------------------+
 | Procedure to update a row in the split percentages table 		      |
 +---------------------------------------------------------------------------*/

PROCEDURE update_row(x_err_code 		OUT NOCOPY NUMBER,
		     x_err_msg                  OUT NOCOPY VARCHAR2,
		     p_rowid                    IN VARCHAR2,
		     p_co_product_id  		IN NUMBER,
		     p_co_product_group_id	IN NUMBER,
		     p_organization_id		IN NUMBER,
		     p_revision			IN VARCHAR2,
		     p_split			IN NUMBER,
		     p_primary_flag		IN VARCHAR2,
		     p_effectivity_date		IN DATE,
		     p_disable_date		IN DATE,
		     p_creation_date		IN DATE,
		     p_created_by 		IN NUMBER,
		     p_last_update_date		IN DATE,
		     p_last_updated_by 		IN NUMBER,
		     p_last_update_login	IN NUMBER,
		     p_attribute_category	IN VARCHAR2,
		     p_attribute1		IN VARCHAR2,
		     p_attribute2		IN VARCHAR2,
		     p_attribute3		IN VARCHAR2,
		     p_attribute4		IN VARCHAR2,
		     p_attribute5		IN VARCHAR2,
		     p_attribute6		IN VARCHAR2,
		     p_attribute7		IN VARCHAR2,
		     p_attribute8		IN VARCHAR2,
		     p_attribute9		IN VARCHAR2,
		     p_attribute10		IN VARCHAR2,
		     p_attribute11		IN VARCHAR2,
		     p_attribute12		IN VARCHAR2,
		     p_attribute13		IN VARCHAR2,
		     p_attribute14		IN VARCHAR2,
		     p_attribute15		IN VARCHAR2,
		     p_request_id               IN NUMBER,
                     p_program_application_id   IN NUMBER,
                     p_program_id               IN NUMBER,
                     p_program_update_date      IN DATE
		     );
 /*---------------------------------------------------------------------------+
 | Lock row procedure							      |
 |									      |
 +---------------------------------------------------------------------------*/

  PROCEDURE lock_row(x_err_code 		OUT NOCOPY NUMBER,
		     x_err_msg                  OUT NOCOPY VARCHAR2,
		     p_rowid                    IN VARCHAR2,
		     p_co_product_id  		IN NUMBER,
		     p_co_product_group_id	IN NUMBER,
		     p_organization_id		IN NUMBER,
		     p_revision			IN VARCHAR2,
		     p_split			IN NUMBER,
		     p_primary_flag		IN VARCHAR2,
		     p_effectivity_date		IN DATE,
		     p_disable_date		IN DATE,
		     p_attribute_category	IN VARCHAR2,
		     p_attribute1		IN VARCHAR2,
		     p_attribute2		IN VARCHAR2,
		     p_attribute3		IN VARCHAR2,
		     p_attribute4		IN VARCHAR2,
		     p_attribute5		IN VARCHAR2,
		     p_attribute6		IN VARCHAR2,
		     p_attribute7		IN VARCHAR2,
		     p_attribute8		IN VARCHAR2,
		     p_attribute9		IN VARCHAR2,
		     p_attribute10		IN VARCHAR2,
		     p_attribute11		IN VARCHAR2,
		     p_attribute12		IN VARCHAR2,
		     p_attribute13		IN VARCHAR2,
		     p_attribute14		IN VARCHAR2,
		     p_attribute15		IN VARCHAR2
		     );

 /*---------------------------------------------------------------------------+
 | Procedure to delete all the entries corresponding to a (co product id,     |
 | co product group id) pair in  the split percentages table 		      |
 +---------------------------------------------------------------------------*/
  PROCEDURE delete_row(x_err_code		OUT NOCOPY NUMBER,
   			x_err_msg		OUT NOCOPY VARCHAR2,
   			p_co_product_id  	IN NUMBER,
		     	p_co_product_group_id	IN NUMBER,
			p_organization_id	IN NUMBER
			);
 /*---------------------------------------------------------------------------+
 | Procedure to delete all the records pertaining to a co product group id in |
 | the split percentages table						      |
 +---------------------------------------------------------------------------*/
 PROCEDURE delete_all_range(x_err_code                OUT NOCOPY NUMBER,
 			    x_err_msg	              OUT NOCOPY VARCHAR2,
			    p_organization_id         IN NUMBER,
			    p_co_product_group_id     IN NUMBER);

 /*---------------------------------------------------------------------------+
 | Procedure to ensure that that no two ranges are overlapping in the time    |
 | frame. Called immediately after inserting a new split eff. range           |
 +---------------------------------------------------------------------------*/

 PROCEDURE process_records (l_co_product_gr_id IN  NUMBER,
         		    from_eff_dt        IN  DATE,
			    to_eff_dt          IN  DATE,
			    x_err_code         OUT NOCOPY NUMBER,
			    x_err_msg	       OUT NOCOPY VARCHAR2);

 /*---------------------------------------------------------------------------+
 | Procdure to check if the update of comp. eff/ disable date will cause      |
 | the deletion of any existent ranges					      |
 +---------------------------------------------------------------------------*/

 /* This procedure is not used as comp. eff./diable date will not be related to the
    co product eff/disable dates */
 FUNCTION validate_range ( p_co_product_group_id  IN NUMBER,
 			   p_organization_id      IN NUMBER,
			   p_effectivity_date     IN DATE,
			   p_disable_date	  IN DATE) RETURN NUMBER;

 /*---------------------------------------------------------------------------+
 | Procdure to update/delete any existent ranges that would be affected by the|
 | the update of comp. eff. date/ disable date  			      |
 +---------------------------------------------------------------------------*/

 /* This procedure is not used as comp. eff./diable date will not be related to the
    co product eff/disable dates */

 PROCEDURE update_split_range(x_err_code 		OUT NOCOPY NUMBER,
			     x_err_msg  		OUT NOCOPY VARCHAR2,
			     p_organization_id          IN NUMBER,
			     p_co_product_group_id      IN NUMBER,
			     p_effectivity_date		IN DATE,
			     p_disable_date		IN DATE,
			     p_update_range             IN NUMBER
			     );

 /*---------------------------------------------------------------------------+
 | Procedure to insert a co-product in all ranges of a co-product group id    |
 | with split perc 0% in case of sec. co-product and 100% in case of          |
 | primary co-product							      |
 +---------------------------------------------------------------------------*/
 PROCEDURE insert_co_product_range(x_err_code 		  OUT NOCOPY NUMBER,
 				   x_err_msg		  OUT NOCOPY VARCHAR2,
 				   p_co_product_group_id  IN NUMBER,
				   p_co_product_id	  IN NUMBER,
				   p_revision		  IN VARCHAR2,
				   p_split      	  IN NUMBER,
				   p_primary_flag 	  IN VARCHAR2,
 			   	   p_organization_id      IN NUMBER,
				   p_effectivity_date     IN DATE,
				   p_disable_date	  IN DATE,
				   p_creation_date	  IN DATE,
				   p_created_by 	  IN NUMBER,
				   p_last_update_date	  IN DATE,
				   p_last_updated_by 	  IN NUMBER
				   );
 /*---------------------------------------------------------------------------+
 | Procedure to check if there is atleast one range in wich the co product    |
 | passed has a non-zero split percentage.. 				      |
 +---------------------------------------------------------------------------*/
 FUNCTION check_split_perc_exists(x_err_code  	        OUT NOCOPY NUMBER,
				  x_err_msg   	        OUT NOCOPY VARCHAR2,
				  p_co_product_id       IN NUMBER,
				  p_co_product_group_id IN NUMBER,
				  p_organization_id     IN NUMBER )  RETURN BOOLEAN;

/*---------------------------------------------------------------------------+
 | Procedure to check if there is atleast one co product of a co-prod group  |
 | in the range passed that has a zero split percentage..	     	     |
 +--------------------------------------------------------------------------*/
FUNCTION check_split_perc_exists(x_err_code  	        OUT NOCOPY NUMBER,
				  x_err_msg   	        OUT NOCOPY VARCHAR2,
				  p_co_product_group_id IN NUMBER,
				  p_organization_id     IN NUMBER,
				  p_effectivity_date    IN DATE,
				  p_disable_date        IN DATE) RETURN BOOLEAN;

 /*---------------------------------------------------------------------------+
 | Procedure to check if a co-product group id had got only one	split 	      |
 | effectivity range							      |
 +---------------------------------------------------------------------------*/
 FUNCTION check_unique_range(x_err_code  	        OUT NOCOPY NUMBER,
		             x_err_msg   	        OUT NOCOPY VARCHAR2,
			     p_co_product_group_id      IN NUMBER,
			     p_organization_id          IN NUMBER )  RETURN BOOLEAN;

 /*---------------------------------------------------------------------------+
 | Procedure to check if the new eff. range ( eff date/ disable date ) 	      |
 | will cause any existing ranges to be deleted				      |
 +---------------------------------------------------------------------------*/

 FUNCTION check_any_del_range ( p_co_product_group_id  IN NUMBER,
 			       p_organization_id      IN NUMBER,
			       p_effectivity_date     IN DATE,
			       p_disable_date	  IN DATE)  RETURN NUMBER;

 /*---------------------------------------------------------------------------+
 | Procedure to check if a range is preexisting			 	      |
 +---------------------------------------------------------------------------*/

FUNCTION check_unique(x_err_code  	        OUT NOCOPY NUMBER,
		      x_err_msg   	        OUT NOCOPY VARCHAR2,
		      p_co_product_group_id      IN NUMBER,
		      p_organization_id          IN NUMBER,
		      p_effectivity_date 	 IN DATE,
		      p_disable_date 		 IN DATE)  RETURN BOOLEAN;

END WSM_SPLIT_PERC_PVT;

 

/
