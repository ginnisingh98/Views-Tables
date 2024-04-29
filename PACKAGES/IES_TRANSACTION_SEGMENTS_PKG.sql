--------------------------------------------------------
--  DDL for Package IES_TRANSACTION_SEGMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_TRANSACTION_SEGMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: iestrss.pls 115.5 2003/05/02 22:53:47 prkotha noship $ */

   PROCEDURE create_Segment (p_transaction_id IN NUMBER,
                             p_user_id IN NUMBER,
                             p_dscript_id IN NUMBER,
                             x_id OUT NOCOPY  NUMBER);


   PROCEDURE update_Segment (p_transaction_id IN NUMBER,
                             p_status IN NUMBER,
                             p_restart_clob IN CLOB,
                             p_user_id IN NUMBER);

END ies_transaction_segments_pkg;

 

/
