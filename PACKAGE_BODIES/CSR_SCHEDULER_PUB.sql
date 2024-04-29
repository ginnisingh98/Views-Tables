--------------------------------------------------------
--  DDL for Package Body CSR_SCHEDULER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSR_SCHEDULER_PUB" AS
  /* $Header: CSRPSCHB.pls 120.0.12010000.1 2009/04/02 12:55:05 venjayar noship $ */

  g_pkg_name            CONSTANT VARCHAR2(30) := 'CSR_SCHEDULER_PUB';

  FUNCTION get_sch_parameter_value(p_parameter_name VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
    RETURN
      csr_rules_pvt.get_sch_parameter_value(
          p_parameter_name  => p_parameter_name
        , p_appl_id         => fnd_global.resp_appl_id
        , p_resp_id         => fnd_global.resp_id
        , p_user_id         => fnd_global.user_id
        );
  END get_sch_parameter_value;

  FUNCTION get_sch_parameter_value(
      p_parameter_name           IN            VARCHAR2
    , p_appl_id                  IN            NUMBER
    , p_resp_id                  IN            NUMBER
    , p_user_id                  IN            NUMBER
    , p_terr_id                  IN            NUMBER      DEFAULT NULL
    , p_resource_type            IN            VARCHAR2    DEFAULT NULL
    , p_resource_id              IN            NUMBER      DEFAULT NULL
    )
    RETURN VARCHAR2 IS
  BEGIN
    RETURN
      csr_rules_pvt.get_sch_parameter_value(
          p_parameter_name  => p_parameter_name
        , p_appl_id         => p_appl_id
        , p_resp_id         => p_resp_id
        , p_user_id         => p_user_id
        , p_terr_id         => p_terr_id
        , p_resource_type   => p_resource_type
        , p_resource_id     => p_resource_id
        );
  END get_sch_parameter_value;
END csr_scheduler_pub;

/
