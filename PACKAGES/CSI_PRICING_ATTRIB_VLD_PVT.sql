--------------------------------------------------------
--  DDL for Package CSI_PRICING_ATTRIB_VLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_PRICING_ATTRIB_VLD_PVT" AUTHID CURRENT_USER AS
/* $Header: csivpavs.pls 120.0.12010000.1 2008/07/25 08:16:23 appldev ship $ */

G_PKG_NAME   VARCHAR2(30) := 'csi_extend_attrib_vld_pvt';

/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_instance_id                    */
/*                                                          */
/* Description  :  This function checks if  instance        */
/*                 ids are valid                            */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_instance_id
       	(p_instance_id    IN      NUMBER
        ,p_event          IN      VARCHAR2
        ,p_stack_err_msg  IN      BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN;



/*----------------------------------------------------------*/
/* Function Name :  Val_inst_id_for_update                  */
/*                                                          */
/* Description  :  This function checks if  instance        */
/*                 ids can be updated                       */
/*----------------------------------------------------------*/

FUNCTION Val_inst_id_for_update
       ( p_instance_id_new   IN      NUMBER
        ,p_instance_id_old   IN      NUMBER
        ,p_stack_err_msg     IN      BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN;



/*----------------------------------------------------------*/
/* Function Name :  Is_StartDate_Valid                      */
/*                                                          */
/* Description  :  This function checks if start date       */
/*                 is valid                                 */
/*----------------------------------------------------------*/

FUNCTION Is_StartDate_Valid
    (p_start_date     IN  OUT NOCOPY DATE,
     p_end_date       IN      DATE,
     p_instance_id    IN      NUMBER,
     p_stack_err_msg  IN      BOOLEAN DEFAULT TRUE
    )
RETURN BOOLEAN;




/*----------------------------------------------------------*/
/* Function Name :  Is_EndDate_Valid                        */
/*                                                          */
/* Description  :  This function checks if end date         */
/*                 is valid                                 */
/*----------------------------------------------------------*/

FUNCTION Is_EndDate_Valid
( p_start_date        IN   DATE,
  p_end_date          IN   DATE,
  p_instance_id       IN   NUMBER,
  p_pricing_attr_id   IN   NUMBER,
  p_txn_id            IN   NUMBER,
  p_stack_err_msg     IN   BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;




/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_pricing_attrib_id              */
/*                                                          */
/* Description  :  This function checks if  pricing_attrib  */
/*                 ids are valid                            */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_pricing_attrib_id
       (p_pricing_attrib_id IN      NUMBER
       ,p_stack_err_msg     IN      BOOLEAN DEFAULT TRUE
       )
RETURN BOOLEAN;



/*----------------------------------------------------------*/
/* Function Name :  Val_and_get_pri_att_id                  */
/*                                                          */
/* Description  :  This function checks if  pricing_attrib  */
/*                 ids are valid and returns values         */
/*----------------------------------------------------------*/

FUNCTION Val_and_get_pri_att_id
       ( p_pricing_attrib_id    IN      NUMBER
        ,p_pricing_attribs_rec  OUT NOCOPY     csi_datastructures_pub.pricing_attribs_rec
        ,p_stack_err_msg        IN      BOOLEAN DEFAULT TRUE
       		   )
RETURN BOOLEAN;




/*----------------------------------------------------------*/
/* Function Name :  Is_Expire_Op                            */
/*                                                          */
/* Description  :  This function checks if it is a          */
/*                 ids are valid and returns values         */
/*----------------------------------------------------------*/

FUNCTION Is_Expire_Op
       (p_pricing_attribs_rec IN      csi_datastructures_pub.pricing_attribs_rec
       ,p_stack_err_msg       IN      BOOLEAN DEFAULT TRUE
       )
RETURN BOOLEAN;



/*----------------------------------------------------------*/
/* Function Name :  Is_Updatable                            */
/*                                                          */
/* Description  :  This function checks if this is a        */
/*                 an updatable record                      */
/*----------------------------------------------------------*/

FUNCTION Is_Updatable
       (p_old_date          IN      DATE
       ,p_new_date          IN      DATE
       ,p_stack_err_msg     IN      BOOLEAN DEFAULT TRUE
       )
RETURN BOOLEAN;





/*----------------------------------------------------------*/
/* Function Name :  get_pricing_attrib_id                   */
/*                                                          */
/* Description  :  This function generates                  */
/*                 pricing_attrib_id using a sequence       */
/*----------------------------------------------------------*/

FUNCTION get_pricing_attrib_id
       ( p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
       )
RETURN NUMBER;




/*----------------------------------------------------------*/
/* Function Name :  get_pricing_attrib_h_id                 */
/*                                                          */
/* Description  :  This function generates                  */
/*                 pricing_attrib_h_id using a sequence     */
/*----------------------------------------------------------*/

FUNCTION get_pricing_attrib_h_id
       ( p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
       )
RETURN NUMBER;




/*-------------------------------------------------------------- */
/* Function Name :  get_object_version_number                    */
/*                                                               */
/* Description  :  This function generates object_version_number */
/*                 using previous version numbers                */
/*---------------------------------------------------------------*/

FUNCTION get_object_version_number
    (p_object_version_number IN      NUMBER
    ,p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
     )
RETURN NUMBER;




/*-------------------------------------------------------------- */
/* Function Name :  Is_valid_obj_ver_num                         */
/*                                                               */
/* Description  :  This function generates object_version_number */
/*                 using previous version numbers                */
/*---------------------------------------------------------------*/

FUNCTION Is_valid_obj_ver_num
        (p_obj_ver_numb_new IN  NUMBER
        ,p_obj_ver_numb_old IN  NUMBER
        ,p_stack_err_msg    IN  BOOLEAN DEFAULT TRUE
         )
RETURN BOOLEAN;




/*-------------------------------------------------------------- */
/* Function Name :  get_full_dump_frequency                      */
/*                                                               */
/* Description  :  This function gets the dump frequency         */
/*---------------------------------------------------------------*/

FUNCTION get_full_dump_frequency
    (p_stack_err_msg IN  BOOLEAN DEFAULT TRUE
     )
RETURN NUMBER;


END csi_pricing_attrib_vld_pvt;

/
