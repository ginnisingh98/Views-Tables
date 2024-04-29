--------------------------------------------------------
--  DDL for Package Body ECX_OXTA_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_OXTA_UTIL_PKG" as
/* $Header: ECXOXUTB.pls 115.5 2002/11/13 11:24:24 ndivakar noship $ */

procedure oxta_insertlog
(
    p_sender_message_id   in  varchar2,
    p_direction           in  varchar2,
    p_status              in  varchar2,
    p_begin_date          in  date,
    p_request_type        in  varchar2,
    p_content_length      in  number,
    p_transaction_type    in  varchar2,
    p_username            in  varchar2,
    p_ip_address          in  varchar2,
    p_protocol_type       in  varchar2,
    p_protocol_address    in  varchar2,
    p_result_code         in  varchar2,
    p_result_text         in  varchar2,
    p_receipt_message_id  in  varchar2,
    p_completed_date      in  date,
    p_exception_text      in  varchar2
) is
pragma AUTONOMOUS_TRANSACTION;
begin
INSERT INTO ECX_OXTA_LOGMSG
  (SENDER_MESSAGE_ID,
    DIRECTION,
    STATUS,
    BEGIN_DATE,
    REQUEST_TYPE,
    CONTENT_LENGTH,
    TRANSACTION_TYPE,
    USERNAME,
    IP_ADDRESS,
    PROTOCOL_TYPE,
    PROTOCOL_ADDRESS,
    RESULT_CODE,
    RESULT_TEXT,
    RECEIPT_MESSAGE_ID,
    COMPLETED_DATE,
    EXCEPTION_TEXT)
  VALUES
  (p_sender_message_id,
    p_direction,
    p_status,
    p_begin_date,
    p_request_type,
    p_content_length,
    p_transaction_type,
    p_username,
    p_ip_address,
    p_protocol_type,
    p_protocol_address,
    p_result_code,
    p_result_text,
    p_receipt_message_id,
    p_completed_date,
    p_exception_text);
commit;
end oxta_insertlog;

end ECX_OXTA_UTIL_PKG;

/
