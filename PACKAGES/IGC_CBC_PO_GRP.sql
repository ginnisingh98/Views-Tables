--------------------------------------------------------
--  DDL for Package IGC_CBC_PO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CBC_PO_GRP" AUTHID CURRENT_USER AS
   -- $Header: IGCBCPOS.pls 120.6.12010000.2 2008/08/04 14:48:30 sasukuma ship $
   --
   --
   --
   -- PUBLIC ROUTINES
   --
   --

/*==========================================================================
             Function Get_Fiscal_Year
===========================================================================*/

             FUNCTION Get_Fiscal_Year(  p_date   IN  DATE
                                       ,p_sob_id IN  NUMBER)
             RETURN number;

/*==========================================================================
             Procedure IS_CBC_ENABLED
===========================================================================*/

   PROCEDURE is_cbc_enabled( p_api_version      IN   NUMBER
                            ,p_init_msg_list    IN   VARCHAR2 := FND_API.G_FALSE
                            ,p_commit           IN   VARCHAR2 := FND_API.G_FALSE
                            ,p_validation_level IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
                            ,x_return_status    OUT  NOCOPY VARCHAR2
                            ,x_msg_count        OUT  NOCOPY NUMBER
                            ,x_msg_data         OUT  NOCOPY VARCHAR2
                            ,x_cbc_enabled      OUT  NOCOPY VARCHAR2);


/*=========================================================================
              Procedure CBC_HEADER_VALIDATIONS
==========================================================================*/

   PROCEDURE cbc_header_validations ( p_api_version        IN   NUMBER
                                     ,p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE
                                     ,p_commit             IN   VARCHAR2 := FND_API.G_FALSE
                                     ,p_validation_level   IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                     ,x_return_status      OUT  NOCOPY VARCHAR2
                                     ,x_msg_count          OUT  NOCOPY NUMBER
                                     ,x_msg_data           OUT  NOCOPY VARCHAR2
                                     ,p_document_id        IN   NUMBER
                                     ,p_document_type      IN   VARCHAR2
                                     ,p_document_sub_type  IN   VARCHAR2);

/*=========================================================================
             Procedure VALID_CBC_ACCT_DATE
==========================================================================*/

   PROCEDURE valid_cbc_acct_date(p_api_version       IN   NUMBER
                                ,p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE
                                ,p_commit            IN   VARCHAR2 := FND_API.G_FALSE
                                ,p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                ,x_return_status     OUT  NOCOPY VARCHAR2
                                ,x_msg_count         OUT  NOCOPY NUMBER
                                ,x_msg_data          OUT  NOCOPY VARCHAR2
                                ,p_document_id       IN   NUMBER
                                ,p_document_type     IN   VARCHAR2
                                ,p_document_sub_type IN   VARCHAR2
                                ,p_cbc_acct_date     IN   DATE);

/*=========================================================================
            Procedure GET_CBC_ACCT_UPDATE
==========================================================================*/

   PROCEDURE get_cbc_acct_date(p_api_version         IN   NUMBER
                               ,p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE
                               ,p_commit             IN   VARCHAR2 := FND_API.G_FALSE
                               ,p_validation_level   IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
                               ,x_return_status      OUT  NOCOPY VARCHAR2
                               ,x_msg_count          OUT  NOCOPY NUMBER
                               ,x_msg_data           OUT  NOCOPY VARCHAR2
                               ,p_document_id        IN   NUMBER
                               ,p_document_type      IN   VARCHAR2
                               ,p_document_sub_type  IN   VARCHAR2
                               ,p_default            IN   VARCHAR2
                               ,x_cbc_acct_date      OUT  NOCOPY DATE );

/*========================================================================
           Procedure UPDATE_CBC_ACCT_DATE
=========================================================================*/

   PROCEDURE update_cbc_acct_date(p_api_version        IN   NUMBER
                                  ,p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE
                                  ,p_commit            IN   VARCHAR2 := FND_API.G_FALSE
                                  ,p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                  ,x_return_status     OUT  NOCOPY VARCHAR2
                                  ,x_msg_count         OUT  NOCOPY NUMBER
                                  ,x_msg_data          OUT  NOCOPY VARCHAR2
                                  ,p_document_id       IN   NUMBER
                                  ,p_document_type     IN   VARCHAR2
                                  ,p_document_sub_type IN   VARCHAR2
                                  ,p_cbc_acct_date     IN   DATE);

/*========================================================================
           Procedure GL_DATE_ROLL_FORWARD
=========================================================================*/

   PROCEDURE gl_date_roll_forward( p_api_version        IN   NUMBER
                                  ,p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE
                                  ,p_commit             IN   VARCHAR2 := FND_API.G_FALSE
                                  ,p_validation_level   IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                  ,x_return_status      OUT  NOCOPY VARCHAR2
                                  ,x_msg_count          OUT  NOCOPY NUMBER
                                  ,x_msg_data           OUT  NOCOPY VARCHAR2
                                  ,p_document_id        IN   VARCHAR2
                                  ,p_document_type      IN   VARCHAR2
                                  ,p_document_sub_type  IN   VARCHAR2
                                  ,p_line_id            IN   VARCHAR2 := NULL
                                  ,p_line_location_id   IN   VARCHAR2 := NULL
                                  ,p_action_date        IN   DATE
                                  ,p_cancel_req         IN   VARCHAR2 );


  -- Package variable to store if CBC is enabled or not.
  -- This variable is used when the procedures are invoked through forms.
  g_is_cbc_po_enabled             VARCHAR2(1);

 -- FUnction to return the package variable to the forms and librarires
  FUNCTION cbc_po_enabled_flag
          RETURN VARCHAR2;

  -- Package variable to store if the User has clicked on 'Cancel'
  -- on the Dual funds Check form IGCDFCHK
  g_fundchk_cancel_flag            VARCHAR2(1);

 -- Function to set the package variable to the forms and librarires
  PROCEDURE set_fundchk_cancel_flag (p_value            IN  VARCHAR2);

 -- Function to get the package variable to the forms and librarires
  FUNCTION fundchk_cancel_flag
          RETURN VARCHAR2;

END igc_cbc_po_grp;


/
