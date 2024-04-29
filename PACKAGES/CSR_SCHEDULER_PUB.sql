--------------------------------------------------------
--  DDL for Package CSR_SCHEDULER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSR_SCHEDULER_PUB" AUTHID CURRENT_USER AS
  /* $Header: CSRPSCHS.pls 120.0.12010000.1 2009/04/02 12:54:08 venjayar noship $ */

  /**
   * Retrieves the value of the given Scheduler Parameter for the current
   * logged in session taking Application ID, Responsibility ID, User ID
   * from FND_GLOBAL.
   *
   * @param  p_parameter_name          Name of the Parameter
   */
  FUNCTION get_sch_parameter_value(p_parameter_name VARCHAR2)
    RETURN VARCHAR2;

  /**
   * Retrieves the value of the given Scheduler Parameter based on the
   * eligibility levels given.
   *
   * @param  p_parameter_name          Name of the Parameter
   * @param  p_appl_id                 ID of the Application for Eligibility (Pass -9999 if no Application)
   * @param  p_resp_id                 ID of the Responsibility for Eligibility (Pass -9999 if no Responsibility)
   * @param  p_user_id                 ID of the User for Eligibility (Pass -9999 if no User)
   * @param  p_terr_id                 ID of the Territory for Eligibility (Optional)
   * @param  p_resource_type           Type of the Resource for Eligibility (Optional)
   * @param  p_resource_id             ID of the Resource for Eligibility (Optional)
   **/
  FUNCTION get_sch_parameter_value(
      p_parameter_name           IN            VARCHAR2
    , p_appl_id                  IN            NUMBER
    , p_resp_id                  IN            NUMBER
    , p_user_id                  IN            NUMBER
    , p_terr_id                  IN            NUMBER      DEFAULT NULL
    , p_resource_type            IN            VARCHAR2    DEFAULT NULL
    , p_resource_id              IN            NUMBER      DEFAULT NULL
    )
    RETURN VARCHAR2;

END csr_scheduler_pub;

/
