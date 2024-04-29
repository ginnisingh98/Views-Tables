--------------------------------------------------------
--  DDL for Package Body QP_BULK_MSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_BULK_MSG" AS
/* $Header: QPXBMSGB.pls 120.1 2006/09/05 22:35:07 rnayani noship $ */

PROCEDURE ADD
          (p_msg_rec  QP_BULK_MSG.MSG_REC_TYPE)
IS
   l_index NUMBER;

BEGIN
   qp_bulk_loader_pub.write_log( 'IN QP_BULK_MSG.ADD');

   l_index := G_msg_rec.request_id.count+1;

   G_msg_rec.request_id(l_index) := p_msg_rec.request_id;
   G_msg_rec.entity_type(l_index) := p_msg_rec.entity_type;
   G_msg_rec.table_name(l_index) := p_msg_rec.table_name;
   G_msg_rec.orig_sys_header_ref(l_index) := p_msg_rec.orig_sys_header_ref;
   G_msg_rec.list_header_id(l_index) := p_msg_rec.list_header_id;
   G_msg_rec.orig_sys_line_ref(l_index) := p_msg_rec.orig_sys_line_ref;
   G_msg_rec.orig_sys_qualifier_ref(l_index) := p_msg_rec.orig_sys_qualifier_ref;
   G_msg_rec.orig_sys_pricing_attr_ref(l_index) := p_msg_rec.orig_sys_pricing_attr_ref;
   --Bug#5512040 RAVI (Constrict message to 240 char)
   G_msg_rec.error_message(l_index) := SUBSTR(fnd_message.get,1,240);

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN QP_BULK_MSG.ADD');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN QP_BULK_MSG.ADD');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END ADD;

PROCEDURE SAVE_MESSAGE
          (p_request_id NUMBER)
IS

l_count_msg NUMBER;

BEGIN
   l_count_msg := G_msg_rec.request_id.COUNT;

   FORALL I IN 1..l_count_msg
     INSERT INTO QP_INTERFACE_ERRORS
		 (
		   ERROR_ID
		  ,LAST_UPDATE_DATE
		  ,LAST_UPDATED_BY
		  ,CREATION_DATE
		  ,CREATED_BY
		  ,LAST_UPDATE_LOGIN
		  ,REQUEST_ID
		  ,PROGRAM_APPLICATION_ID
		  ,PROGRAM_ID
		  ,PROGRAM_UPDATE_DATE
		  ,ENTITY_TYPE
		  ,TABLE_NAME
		  ,ORIG_SYS_HEADER_REF
		  ,ORIG_SYS_LINE_REF
		  ,ORIG_SYS_QUALIFIER_REF
		  ,ORIG_SYS_PRICING_ATTR_REF
		  ,ERROR_MESSAGE
		  )
     VALUES
      (
       QP_INTERFACE_ERRORS_S.NEXTVAL
       ,sysdate
       ,FND_GLOBAL.USER_ID
       ,sysdate
       ,FND_GLOBAL.USER_ID
       ,FND_GLOBAL.CONC_LOGIN_ID
       ,G_MSG_REC.REQUEST_ID(I)
       ,660
       ,NULL
       ,NULL
       ,G_MSG_REC.entity_type(I)
       ,G_MSG_REC.table_name(I)
       ,G_MSG_REC.ORIG_SYS_HEADER_REF(I)
       ,G_MSG_REC.ORIG_SYS_LINE_REF(I)
       ,G_MSG_REC.ORIG_SYS_QUALIFIER_REF(I)
       ,G_MSG_REC.ORIG_SYS_PRICING_ATTR_REF(I)
       ,G_MSG_REC.error_message(I)
       );

      G_MSG_REC.entity_type.delete;
      G_MSG_REC.request_id.delete;
      G_MSG_REC.table_name.delete;
      G_MSG_REC.orig_sys_header_ref.delete;
      G_MSG_REC.orig_sys_line_ref.delete;
      G_MSG_REC.orig_sys_qualifier_ref.delete;
      G_MSG_REC.orig_sys_pricing_attr_ref.delete;
      G_MSG_REC.error_message.delete;

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN QP_BULK_MSG.SAVE_MESSAGE');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN QP_BULK_MSG.SAVE_MESSSAGE');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END SAVE_MESSAGE;

END QP_BULK_MSG;

/
