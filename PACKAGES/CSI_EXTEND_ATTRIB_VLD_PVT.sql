--------------------------------------------------------
--  DDL for Package CSI_EXTEND_ATTRIB_VLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_EXTEND_ATTRIB_VLD_PVT" AUTHID CURRENT_USER AS
/* $Header: csiveavs.pls 120.0.12010000.1 2008/07/25 08:15:36 appldev ship $ */

/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_instance_id                    */
/*                                                          */
/* Description  :  This function checks if  instance        */
/*                 ids are valid                            */
/*----------------------------------------------------------*/
FUNCTION Is_Valid_instance_id
              ( p_instance_id       IN      NUMBER
               ,p_event             IN      VARCHAR2
               ,p_inventory_item_id OUT NOCOPY     NUMBER
               ,p_inv_master_org_id OUT NOCOPY     NUMBER
               ,p_stack_err_msg     IN      BOOLEAN DEFAULT TRUE)
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
/* Function Name :  Val_and_get_ext_att_id                  */
/*                                                          */
/* Description  :  This function gets attribute values      */
/*                                                          */
/*----------------------------------------------------------*/

FUNCTION Val_and_get_ext_att_id
              (  p_att_value_id       IN         NUMBER
                ,p_ext_attrib_rec         OUT NOCOPY    csi_datastructures_pub.extend_attrib_values_rec
                ,p_stack_err_msg      IN         BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN;



/*----------------------------------------------------------*/
/* Function Name :  Is_Expire_Op                            */
/*                                                          */
/* Description  :  This function checks if it is a          */
/*                 ids are valid and returns values         */
/*----------------------------------------------------------*/

FUNCTION Is_Expire_Op
          (p_ext_attrib_rec    IN    csi_datastructures_pub.extend_attrib_values_rec
          ,p_stack_err_msg     IN    BOOLEAN DEFAULT TRUE
          )
RETURN BOOLEAN;



/*----------------------------------------------------------*/
/* Function Name :  Is_Updatable                            */
/*                                                          */
/* Description  :  This function checks if this is a        */
/*                 an updatable record                      */
/*----------------------------------------------------------*/

FUNCTION Is_Updatable
       (p_old_date         IN  DATE
       ,p_new_date         IN  DATE
       ,p_stack_err_msg    IN  BOOLEAN DEFAULT TRUE
       )
RETURN BOOLEAN;




/*----------------------------------------------------------*/
/* Function Name :  Alternate_PK_exists                     */
/*                                                          */
/* Description  :  This function checks if alternate        */
/*                 PK's are valid                           */
/*----------------------------------------------------------*/

FUNCTION Alternate_PK_exists
     ( p_instance_id    IN     NUMBER
      ,p_attribute_id   IN     NUMBER
      ,p_stack_err_msg  IN     BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN;



/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_attribute_id                   */
/*                                                          */
/* Description  :  This function checks if attribute        */
/*                 ids are valid                            */
/*----------------------------------------------------------*/
FUNCTION Is_Valid_attribute_id
     (p_attribute_id              IN         NUMBER
     ,p_attribute_level              OUT NOCOPY     VARCHAR2
     ,p_master_organization_id       OUT NOCOPY     NUMBER
     ,p_inventory_item_id            OUT NOCOPY     NUMBER
     ,p_item_category_id             OUT NOCOPY     NUMBER
     ,p_instance_id                  OUT NOCOPY     NUMBER
     ,p_stack_err_msg             IN         BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN;



/*----------------------------------------------------------*/
/* Function Name :  Is_StartDate_Valid                      */
/*                                                          */
/* Description  :  This function checks if start date       */
/*                 is valid                                 */
/*----------------------------------------------------------*/

FUNCTION Is_StartDate_Valid
  ( p_start_date            IN   OUT NOCOPY    DATE,
    p_end_date              IN          DATE,
    p_instance_id           IN          NUMBER,
    p_stack_err_msg         IN          BOOLEAN  DEFAULT TRUE
  ) RETURN BOOLEAN;




/*----------------------------------------------------------*/
/* Function Name :  Is_EndDate_Valid                        */
/*                                                          */
/* Description  :  This function checks if end date         */
/*                 is valid                                 */
/*----------------------------------------------------------*/
FUNCTION Is_EndDate_Valid
   ( p_start_date            IN   DATE,
     p_end_date              IN   DATE,
     p_instance_id           IN   NUMBER,
     p_attr_value_id         IN   NUMBER,
     p_txn_id                IN   NUMBER,
     p_stack_err_msg         IN   BOOLEAN DEFAULT TRUE
   ) RETURN BOOLEAN;

/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_attribute_level_content        */
/*                                                          */
/* Description  :  This function checks if                  */
/*                 attribute_leve is valid                  */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_attrib_level_content
         (p_attribute_level           IN   VARCHAR2
         ,p_master_organization_id    IN   NUMBER
         ,p_inventory_item_id         IN   NUMBER
         ,p_item_category_id          IN   NUMBER
         ,p_instance_id               IN   NUMBER
         ,p_orig_instance_id          IN   NUMBER
         ,p_orig_inv_item_id          IN   NUMBER
         ,p_orig_master_org_id        IN   NUMBER
         ,p_stack_err_msg             IN   BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN;




/*----------------------------------------------------------*/
/* Function Name :  Is_Valid_attribute_value_id             */
/*                                                          */
/* Description  :  This function checks if                  */
/*                 instance_ou_id is valid                  */
/*----------------------------------------------------------*/

FUNCTION Is_Valid_attribute_value_id
              ( p_attribute_value_id    IN      NUMBER
               ,p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN;




/*----------------------------------------------------------*/
/* Function Name :  Get_instance_ou_id                      */
/*                                                          */
/* Description  :  This function generates                  */
/*                 instance_ou_ids using a sequence         */
/*----------------------------------------------------------*/
FUNCTION Get_attribute_value_id
       ( p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
       )
RETURN NUMBER;




/*----------------------------------------------------------*/
/* Function Name :  get_attribute_value_h_id                */
/*                                                          */
/* Description  :  This function generates                  */
/*                 attribute_value_h_id using a sequence    */
/*----------------------------------------------------------*/
FUNCTION get_attribute_value_h_id
       ( p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
       )
RETURN NUMBER;





/*-------------------------------------------------------------- */
/* Function Name :  get_full_dump_frequency                      */
/*                                                               */
/* Description  :  This function gets the dump frequency         */
/*                                                               */
/*---------------------------------------------------------------*/
FUNCTION get_full_dump_frequency
    (p_stack_err_msg IN  BOOLEAN DEFAULT TRUE
     )
RETURN NUMBER;



/*-------------------------------------------------------------- */
/* Function Name :  Is_valid_obj_ver_num                         */
/*                                                               */
/* Description  :  This function generates object_version_number */
/*                 using previous version numbers                */
/*---------------------------------------------------------------*/
FUNCTION Is_valid_obj_ver_num
       (  p_obj_ver_numb_new IN  NUMBER
         ,p_obj_ver_numb_old IN  NUMBER
         ,p_stack_err_msg    IN  BOOLEAN DEFAULT TRUE
         )
RETURN BOOLEAN;



/*-------------------------------------------------------------- */
/* Function Name :  get_object_version_number                    */
/*                                                               */
/* Description  :  This function generates object_version_number */
/*                 using previous version numbers                */
/*---------------------------------------------------------------*/

FUNCTION get_object_version_number
       (p_object_version_number IN     NUMBER
        ,p_stack_err_msg        IN     BOOLEAN DEFAULT TRUE
        )
RETURN NUMBER;


END csi_extend_attrib_vld_pvt;

/
