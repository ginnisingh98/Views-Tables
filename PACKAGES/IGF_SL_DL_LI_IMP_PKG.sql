--------------------------------------------------------
--  DDL for Package IGF_SL_DL_LI_IMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_LI_IMP_PKG" AUTHID CURRENT_USER AS
  /* $Header: IGFSL20S.pls 120.0 2005/06/01 14:15:32 appldev noship $ */

PROCEDURE run(  errbuf         IN OUT NOCOPY VARCHAR2,
                 retcode        IN OUT NOCOPY NUMBER,
                 p_awd_yr       IN VARCHAR2,
                 p_batch_id     IN NUMBER,
                 p_delete_flag  IN VARCHAR2
               );

TYPE message_rec IS RECORD
                (field_name    VARCHAR2(30),
                 msg_text      VARCHAR2(2000));

TYPE igf_sl_message_table IS TABLE OF message_rec
                               INDEX BY BINARY_INTEGER;
END IGF_SL_DL_LI_IMP_PKG;

 

/
