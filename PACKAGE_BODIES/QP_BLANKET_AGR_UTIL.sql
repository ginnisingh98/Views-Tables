--------------------------------------------------------
--  DDL for Package Body QP_BLANKET_AGR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_BLANKET_AGR_UTIL" AS
/* $Header: QPXBKUTB.pls 120.0 2005/06/02 00:03:15 appldev noship $ */
FUNCTION GET_ATTRIBUTE_CODE(
                             p_FlexField_Name      IN  VARCHAR2,
                             p_Context_Name        IN  VARCHAR2,
                             p_attribute           IN  VARCHAR2 ) RETURN VARCHAR2 IS

x_attribute_code QP_SEGMENTS_TL.seeded_segment_name%TYPE;
x_segment_name   QP_SEGMENTS_B.SEGMENT_CODE%TYPE;
l_debug VARCHAR2(3);
l_routine_name VARCHAR2(30) := 'GET_ATTRIBUTE_CODE';
BEGIN
 l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
 IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('START:'||G_PKG_NAME||':GET_ATTRIBUTE_CODE: Entering');
 END IF;
 QP_UTIL.Get_Attribute_Code(p_FlexField_Name => p_FlexField_Name,
                            p_Context_Name   => p_Context_Name,
                            p_attribute      => p_attribute,
                            x_attribute_code => x_attribute_code,
                            x_segment_name   => x_segment_name);
 IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('END:'||G_PKG_NAME||':GET_ATTRIBUTE_CODE: Exiting');
 END IF;


RETURN(x_attribute_code);
EXCEPTION
WHEN OTHERS THEN
       IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug(G_PKG_NAME||':GET_ATTRIBUTE_CODE: In the exception section');
       END IF;
       FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name => G_PKG_NAME,
                p_procedure_name => l_routine_name);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_ATTRIBUTE_CODE;


END QP_BLANKET_AGR_UTIL;

/
