--------------------------------------------------------
--  DDL for Package Body PO_UDA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_UDA_PUB" AS
/* $Header: PO_UDA_PUB.plb 120.1.12010000.2 2010/05/13 10:43:05 vssrivat noship $ */
d_pkg_name CONSTANT varchar2(50) :=  PO_LOG.get_package_base('PO_UDA_PUB');

/*
mode take two possible values - 'INTERNAL_VALUE', 'DISPLAY_VALUE'.
*/

PROCEDURE GET_ATTR_VALUE (
                          p_template_id                  IN NUMBER DEFAULT NULL,
                          p_entity_code                  IN VARCHAR2 DEFAULT null,
                          pk1_value                      IN VARCHAR2 DEFAULT NULL,
                          pk2_value                      IN VARCHAR2 DEFAULT NULL,
                          pk3_value                      IN VARCHAR2 DEFAULT NULL,
                          pk4_value                      IN VARCHAR2 DEFAULT NULL,
                          pk5_value                      IN VARCHAR2 DEFAULT NULL,
                          p_attr_grp_id                  IN NUMBER DEFAULT NULL,
                          p_attr_grp_int_name            IN VARCHAR2 DEFAULT NULL,
                          p_attr_id                      IN NUMBER DEFAULT NULL,
                          p_attr_int_name                IN VARCHAR2 DEFAULT NULL,
                          p_mode                         IN VARCHAR2 DEFAULT 'INTERNAL_VALUE',
                          p_attr_grp_pk_tbl              IN PO_TBL_VARCHAR4000 DEFAULT NULL,
                          x_multi_row_code               OUT NOCOPY VARCHAR2,
                          x_single_attr_value            OUT NOCOPY VARCHAR2,
                          x_multi_attr_value             OUT NOCOPY PO_TBL_VARCHAR4000,
                          x_return_status                OUT NOCOPY VARCHAR2,
                          x_msg_data                     OUT NOCOPY VARCHAR2
                          )
is

BEGIN
    NULL;
END GET_ATTR_VALUE;


FUNCTION GET_ADDRESS_ATTR_VALUE (
                          p_template_id                  IN NUMBER,
                          p_entity_code                  IN VARCHAR2,
                          pk1_value                      IN NUMBER,
                          pk2_value                      IN NUMBER,
                          pk3_value                      IN NUMBER,
                          pk4_value                      IN NUMBER,
                          pk5_value                      IN NUMBER,
                          p_attr_grp_id                  IN NUMBER,
                          p_attr_grp_int_name            IN VARCHAR2,
                          p_attr_id                      IN NUMBER,
                          p_attr_int_name                IN VARCHAR2,
                          p_address_type                 IN VARCHAR2,
                          p_mode                         IN VARCHAR2 DEFAULT 'DISPLAY_VALUE'
                          )  RETURN VARCHAR2
is
BEGIN
    NULL;
END GET_ADDRESS_ATTR_VALUE;


function get_multi_attr_value (
                          p_template_id                  IN NUMBER,
                          p_entity_code                  IN VARCHAR2,
                          pk1_value                      IN NUMBER,
                          pk2_value                      IN NUMBER,
                          pk3_value                      IN NUMBER,
                          pk4_value                      IN NUMBER,
                          pk5_value                      IN NUMBER,
                          p_attr_grp_id                  IN NUMBER,
                          p_attr_grp_int_name            IN VARCHAR2,
                          p_attr_id                      IN NUMBER,
                          p_attr_int_name                IN VARCHAR2,
                          p_attr_grp_pk_tbl              IN PO_TBL_VARCHAR4000 DEFAULT NULL,
                          p_mode                         IN VARCHAR2 DEFAULT 'INTERNAL_VALUE'
                          )  RETURN PO_TBL_VARCHAR4000
IS
BEGIN
    NULL;
END get_multi_attr_value;

function get_single_attr_value
        (
                p_template_id                  IN NUMBER DEFAULT NULL,
                p_entity_code                  IN VARCHAR2 DEFAULT null,
                pk1_value                      IN VARCHAR2 DEFAULT NULL,
                pk2_value                      IN VARCHAR2 DEFAULT NULL,
                pk3_value                      IN VARCHAR2 DEFAULT NULL,
                pk4_value                      IN VARCHAR2 DEFAULT NULL,
                pk5_value                      IN VARCHAR2 DEFAULT NULL,
                p_attr_grp_id                  IN NUMBER DEFAULT NULL,
                p_attr_grp_int_name            IN VARCHAR2 DEFAULT NULL,
                p_attr_id                      IN NUMBER DEFAULT NULL,
                p_attr_int_name                IN VARCHAR2 DEFAULT NULL,
                p_mode                         IN VARCHAR2 DEFAULT 'INTERNAL_VALUE'
        )  RETURN VARCHAR2
IS
BEGIN
    NULL;
END get_single_attr_value;

END PO_UDA_PUB;

/
