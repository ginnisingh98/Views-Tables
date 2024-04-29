--------------------------------------------------------
--  DDL for Package Body RCV_ASN_ATTACHMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_ASN_ATTACHMENT_PKG" AS
/* $Header: RCVASNAB.pls 120.1 2006/06/24 03:02:37 hvadlamu noship $*/


  g_pkg_name CONSTANT VARCHAR2(50) := 'RCV_ASN_ATTACHMENT_PKG';
  g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

  -- Read the profile option that enables/disables the debug log
  g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


  g_asn_attach_id_tbl asn_attach_id_tbl_type;



PROCEDURE copy_asn_line_attachment (
		p_api_version		IN 	NUMBER,
		p_init_msg_list		IN 	VARCHAR2,
		x_return_status		OUT 	NOCOPY VARCHAR2,
		x_msg_count		OUT 	NOCOPY NUMBER,
		x_msg_data          	OUT 	NOCOPY VARCHAR2,
		p_interface_txn_id	IN 	NUMBER,
		p_shipment_line_id	IN 	NUMBER )

IS

  l_api_name		CONSTANT VARCHAR2(30) := 'COPY_ASN_LINE_ATTACHMENT';
  l_api_version		CONSTANT NUMBER := 1.0;

  l_asn_attach_id	NUMBER      	:= 0;
  l_counter		NUMBER;
  l_created_by		NUMBER;
  l_last_update_login		NUMBER;
  l_attch_exist_flag    VARCHAR2(1) 	:= 'N';


  CURSOR l_asn_attach_id_cur IS
    select rti.asn_attach_id,rti.created_by,rti.last_update_login
    from   fnd_attached_documents fad,
           rcv_transactions_interface rti
    where  rti.interface_transaction_id = p_interface_txn_id
    and    rti.asn_attach_id is not null
    and    to_char(rti.asn_attach_id) = fad.PK1_value
    and    fad.entity_name = 'ASN_ATTACH';

BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
				     l_api_name, g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  BEGIN
    OPEN l_asn_attach_id_cur;
    FETCH l_asn_attach_id_cur INTO
	  l_asn_attach_id,l_created_by,l_last_update_login;
    CLOSE l_asn_attach_id_cur;

    EXCEPTION
      WHEN OTHERS THEN
        l_asn_attach_id := 0;
        X_RETURN_STATUS := FND_API.g_ret_sts_error;

        IF l_asn_attach_id_cur%ISOPEN THEN
          CLOSE l_asn_attach_id_cur;
        END IF;
    END;


  /* If Attachment exist for the line then call FND api to copy attachments. */
  if (l_asn_attach_id <> 0) then

    BEGIN
      fnd_attached_documents2_pkg.copy_attachments(
         X_from_entity_name 		=> 'ASN_ATTACH',
	 X_from_pk1_value 		=> to_char(l_asn_attach_id),
	 X_to_entity_name 		=> 'RCV_LINES',
	 X_to_pk1_value 		=> to_char(p_shipment_line_id),
	x_created_by			=> l_created_by,
	x_last_update_login		=> l_last_update_login);


    EXCEPTION
      WHEN OTHERS THEN
        X_RETURN_STATUS := FND_API.g_ret_sts_error;
    END;

    commit;

    IF (g_asn_attach_id_tbl.count = 0) THEN
      g_asn_attach_id_tbl(0) := l_asn_attach_id;

    ELSE

      FOR l_counter IN 0..g_asn_attach_id_tbl.count - 1 LOOP
        IF (l_asn_attach_id = g_asn_attach_id_tbl(l_counter)) THEN
          l_attch_exist_flag := 'Y';
          exit;
        END IF;

      END LOOP;

      IF (l_attch_exist_flag = 'N') THEN
        g_asn_attach_id_tbl(l_counter + 1) := l_asn_attach_id;
      END IF;

    END IF;

  end if;   /* end if (l_asn_attach_id <> 0) */

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      IF (g_fnd_debug = 'Y') THEN
        asn_debug.put_line('Unexpected error '||sqlcode,FND_LOG.level_unexpected);
      END IF;
    END IF;
    raise;
END copy_asn_line_attachment;




PROCEDURE delete_asn_intf_attachments (
		p_api_version		IN 	NUMBER,
		p_init_msg_list		IN  	VARCHAR2,
		x_return_status		OUT 	NOCOPY VARCHAR2,
		x_msg_count         	OUT 	NOCOPY NUMBER,
		x_msg_data          	OUT 	NOCOPY VARCHAR2 )

IS

  l_counter		NUMBER;
  l_asn_attach_id	NUMBER;
  l_api_name	CONSTANT VARCHAR2(30) := 'DELETE_ASN_INTF_ATTACHMENTS';
  l_api_version	CONSTANT NUMBER := 1.0;


BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
				     l_api_name, g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF (g_asn_attach_id_tbl.count > 0) THEN

    FOR l_counter IN 0..g_asn_attach_id_tbl.count - 1 LOOP
      l_asn_attach_id := g_asn_attach_id_tbl(l_counter);

      IF (l_asn_attach_id is not null) THEN

        BEGIN
          delete_line_attachment (
		p_api_version	=> p_api_version,
		p_init_msg_list	=> p_init_msg_list,
                x_return_status => x_return_status,
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data,
		p_asn_attach_id => l_asn_attach_id );

        EXCEPTION
          WHEN OTHERS THEN
            X_RETURN_STATUS := FND_API.g_ret_sts_error;
        END;

      END IF;
    END LOOP;

  END IF;

  commit;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      IF (g_fnd_debug = 'Y') THEN
        asn_debug.put_line('Unexpected error '||sqlcode,FND_LOG.level_unexpected);
      END IF;
    END IF;

END delete_asn_intf_attachments;



PROCEDURE delete_line_attachment (
		p_api_version		IN 	NUMBER,
		p_init_msg_list		IN  	VARCHAR2,
		x_return_status		OUT 	NOCOPY VARCHAR2,
		x_msg_count		OUT 	NOCOPY NUMBER,
		x_msg_data          	OUT 	NOCOPY VARCHAR2,
		p_asn_attach_id 	IN  	NUMBER )

IS

  l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_LINE_ATTACHMENT';
  l_api_version		CONSTANT NUMBER := 1.0;

  l_datatype_id		NUMBER := 0;
  l_delete_doc_flag	VARCHAR2(1) := 'Y';

  CURSOR l_doctype_cur IS
      SELECT FD.datatype_id
      FROM   FND_DOCUMENTS FD,
             FND_ATTACHED_DOCUMENTS FAD
      WHERE  FAD.entity_name = 'ASN_ATTACH'
      AND    FAD.pk1_value = to_char(p_asn_attach_id)
      AND    FD.document_id = FAD.document_id;

BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
				     l_api_name, g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_asn_attach_id is not null) THEN

    BEGIN
      OPEN l_doctype_cur;
      LOOP
         FETCH l_doctype_cur INTO l_datatype_id;
         EXIT WHEN l_doctype_cur%NOTFOUND;
         IF (l_datatype_id = 5) THEN
            EXIT;
         END IF;

      END LOOP;
      CLOSE l_doctype_cur;

    EXCEPTION
      WHEN OTHERS THEN
        l_datatype_id := 0;

        IF l_doctype_cur%ISOPEN THEN
          CLOSE l_doctype_cur;
        END IF;
    END;

    /* Do not delete URL document since it was not copied. */
    IF (l_datatype_id = 5) THEN
       l_delete_doc_flag := 'N';
    END IF;

    BEGIN
      fnd_attached_documents2_pkg.delete_attachments(
		X_entity_name 		=> 'ASN_ATTACH',
		X_pk1_value 		=> to_char(p_asn_attach_id),
		X_delete_document_flag 	=> l_delete_doc_flag);

    EXCEPTION
      WHEN OTHERS THEN
        X_RETURN_STATUS := FND_API.g_ret_sts_error;
    END;

  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      IF (g_fnd_debug = 'Y') THEN
        asn_debug.put_line('Unexpected error '||sqlcode,FND_LOG.level_unexpected);
      END IF;
    END IF;

END delete_line_attachment;


END RCV_ASN_ATTACHMENT_PKG;

/
