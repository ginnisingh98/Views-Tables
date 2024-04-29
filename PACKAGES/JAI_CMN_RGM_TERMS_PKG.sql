--------------------------------------------------------
--  DDL for Package JAI_CMN_RGM_TERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RGM_TERMS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rgm_term.pls 120.1 2005/07/20 12:57:36 avallabh ship $ */

/***************************************************************************************************
CREATED BY       : rallamse
CREATED DATE     : 25-FEB-2005
ENHANCEMENT BUG  :
PURPOSE          : To provide claim term information
CALLED FROM      :

***************************************************************************************************/

PROCEDURE generate_term_schedules
                               (
                                p_term_id       IN          JAI_RGM_TERMS.TERM_ID%TYPE                ,
                                p_amount        IN          NUMBER                                    ,
                                p_register_date IN          DATE                                      ,
                                p_schedule_id   OUT NOCOPY  JAI_RGM_TRM_SCHEDULES_T.SCHEDULE_ID%TYPE  ,
                                p_process_flag  OUT NOCOPY  VARCHAR2                                  ,
                                p_process_msg   OUT NOCOPY  VARCHAR2
                               );

PROCEDURE get_term_id
                    (
                     p_regime_id         IN           JAI_RGM_TERM_ASSIGNS.REGIME_ID         %TYPE  ,
                     p_item_id           IN           NUMBER                                        ,
                     p_organization_id   IN           JAI_RGM_TERM_ASSIGNS.ORGANIZATION_ID   %TYPE  ,
                     p_party_type        IN           JAI_RGM_TERM_ASSIGNS.ORGANIZATION_TYPE %TYPE  ,
                     p_location_id       IN           JAI_RGM_TERM_ASSIGNS.LOCATION_ID       %TYPE  ,
                     p_term_id           OUT  NOCOPY  JAI_RGM_TERM_ASSIGNS.TERM_ID           %TYPE  ,
                     p_process_flag      OUT  NOCOPY  VARCHAR2                                      ,
                     p_process_msg       OUT  NOCOPY  VARCHAR2
                    );

PROCEDURE set_term_in_use
                       (
                        p_term_id       IN          JAI_RGM_TERMS.TERM_ID%TYPE ,
                        p_process_flag  OUT NOCOPY  VARCHAR2                   ,
                        p_process_msg   OUT NOCOPY  VARCHAR2
                       );

END jai_cmn_rgm_terms_pkg;
 

/
