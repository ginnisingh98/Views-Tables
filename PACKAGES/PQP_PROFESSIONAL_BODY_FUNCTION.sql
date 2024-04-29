--------------------------------------------------------
--  DDL for Package PQP_PROFESSIONAL_BODY_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PROFESSIONAL_BODY_FUNCTION" AUTHID CURRENT_USER AS
-- $Header: pqgbpbfn.pkh 115.4 2003/02/14 19:19:43 tmehra noship $
-----------------------------------------------------------------------------
-- GET_ORGANIZATION_INFO
-----------------------------------------------------------------------------
FUNCTION  get_organization_info (p_element_type_id   IN      NUMBER -- Context
                                ,p_business_group_id IN      NUMBER -- Context
                                ,p_organization_id      OUT NOCOPY  NUMBER
                                ,p_error_message        OUT NOCOPY  VARCHAR2
                                )
RETURN NUMBER;

-----------------------------------------------------------------------------
-- GET_PB_MEM_INFO
-----------------------------------------------------------------------------
FUNCTION  get_pb_mem_info (p_assignment_id        IN     NUMBER -- Context
                          ,p_business_group_id    IN     NUMBER -- Context
                          ,p_organization_id      IN     NUMBER
                          ,p_pay_start_dt         IN      DATE
                          ,p_pay_end_dt           IN      DATE
                          ,p_professional_body_nm     OUT NOCOPY VARCHAR2
                          ,p_membership_category      OUT NOCOPY VARCHAR2
                          ,p_error_message            OUT NOCOPY VARCHAR2
                          )
RETURN NUMBER;

-----------------------------------------------------------------------------
-- GET_PB_UDT_INFO
-----------------------------------------------------------------------------
FUNCTION  get_pb_udt_info (p_business_group_id   IN     NUMBER -- Context
                          ,p_organization_id     IN     NUMBER
                          ,p_membership_category IN     VARCHAR2
                          ,p_user_table_name        OUT NOCOPY VARCHAR2
                          ,p_user_row_value         OUT NOCOPY VARCHAR2
                          ,p_error_message          OUT NOCOPY VARCHAR2
                          )
RETURN NUMBER;

-----------------------------------------------------------------------------

END pqp_professional_body_function;

 

/
