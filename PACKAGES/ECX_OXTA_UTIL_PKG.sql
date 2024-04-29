--------------------------------------------------------
--  DDL for Package ECX_OXTA_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_OXTA_UTIL_PKG" AUTHID CURRENT_USER as
/* $Header: ECXOXUTS.pls 115.5 2002/11/13 11:24:16 ndivakar noship $ */

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
);

end ECX_OXTA_UTIL_PKG;

 

/
