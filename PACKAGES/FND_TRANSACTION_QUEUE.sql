--------------------------------------------------------
--  DDL for Package FND_TRANSACTION_QUEUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_TRANSACTION_QUEUE" AUTHID CURRENT_USER as
/* $Header: AFCPTRQS.pls 120.0 2005/09/02 18:56:50 pferguso noship $ */



function get_manager(application   in  varchar2,
                     program       in  varchar2,
                     timeout       in  number) return number;



function send_message( timeout             in number,
                        send_type          in varchar2,
                        expiration_time    in date,
                        request_id         in number,
                        nls_lang           in varchar2,
                        nls_num_chars      in varchar2,
                        nls_date_lang      in varchar2,
                        secgrpid           in number,
                        enable_trace_flag  in varchar2,
                        application        in varchar2,
                        program            in varchar2,
                        org_type           in varchar2,
                        org_id             in number,
                        outcome in out nocopy varchar2,
                        message in out nocopy varchar2,
                        arg_1              in varchar2,
                        arg_2              in varchar2,
                        arg_3              in varchar2,
                        arg_4              in varchar2,
                        arg_5              in varchar2,
                        arg_6              in varchar2,
                        arg_7              in varchar2,
                        arg_8              in varchar2,
                        arg_9              in varchar2,
                        arg_10             in varchar2,
                        arg_11             in varchar2,
                        arg_12             in varchar2,
                        arg_13             in varchar2,
                        arg_14             in varchar2,
                        arg_15             in varchar2,
                        arg_16             in varchar2,
                        arg_17             in varchar2,
                        arg_18             in varchar2,
                        arg_19             in varchar2,
                        arg_20             in varchar2) return number;


end FND_TRANSACTION_QUEUE;

 

/
