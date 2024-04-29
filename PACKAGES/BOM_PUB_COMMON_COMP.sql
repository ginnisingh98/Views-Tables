--------------------------------------------------------
--  DDL for Package BOM_PUB_COMMON_COMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_PUB_COMMON_COMP" AUTHID DEFINER AS
/* $Header: BOMPCOMS.pls 120.0.12010000.3 2012/08/22 03:53:56 yingyang noship $ */

  G_CUSTOM_MODE_ENABLED      CONSTANT  VARCHAR2(1) := 'N'; --possible values 'Y', 'N'; Default value: N

  PROCEDURE ASSIGN_COMP_TO_ORGS(
        p_api_version                   IN  NUMBER,
        p_revised_item_id               IN  NUMBER,
        p_organization_id               IN  NUMBER,
        p_bill_sequence_id              IN  NUMBER    DEFAULT NULL,
        p_alt_bom_designator            IN  VARCHAR2,
        p_component_item_id             IN  NUMBER,
        p_eco_name                      IN  VARCHAR2  DEFAULT NULL,
        x_return_status                 IN  OUT NOCOPY   VARCHAR2,          -- possible value FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_SUCCESS,FND_API.G_RET_STS_UNEXP_ERROR
        x_Mesg_Token_Tbl	              IN OUT NOCOPY  Error_Handler.Mesg_Token_Tbl_Type) ;

  PROCEDURE ASSIGN_ECO_COMP_TO_ORGS(
        p_api_version                   IN  NUMBER,
        p_organization_id               IN  NUMBER,
        p_bill_sequence_id              IN  NUMBER    DEFAULT NULL,
        x_return_status                 IN OUT NOCOPY   VARCHAR2,
        x_msg_data                      IN OUT NOCOPY  VARCHAR2);

  PROCEDURE ASSIGN_COMP_TO_ORGS_JAVA(
        p_api_version                   IN  NUMBER,
        p_revised_item_id               IN  NUMBER,
        p_organization_id               IN  NUMBER,
        p_bill_sequence_id              IN  NUMBER    DEFAULT NULL,
        p_alt_bom_designator            IN  VARCHAR2,
        p_component_item_id             IN  NUMBER,
        p_eco_name                      IN  VARCHAR2  DEFAULT NULL,
        x_return_status                 IN  OUT NOCOPY   VARCHAR2,
        x_error_message                  IN OUT NOCOPY  VARCHAR2) ;

  FUNCTION GET_CUSTOM_MODE (p_api_version                   IN  NUMBER )
  RETURN VARCHAR;



END BOM_PUB_COMMON_COMP;

/
