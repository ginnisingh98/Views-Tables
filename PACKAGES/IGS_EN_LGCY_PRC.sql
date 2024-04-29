--------------------------------------------------------
--  DDL for Package IGS_EN_LGCY_PRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_LGCY_PRC" AUTHID CURRENT_USER AS
/* $Header: IGSEN99S.pls 115.1 2002/11/28 12:39:06 amuthu noship $ */

/*****************************************************************************
 Who     When        What
 amuthu   21-NOV-2002 Modified as per the Legacy Import prcess
                      TD for EN and REC
******************************************************************************/
  PROCEDURE legacy_batch_process(
              errbuf        OUT NOCOPY VARCHAR2,
              retcode       OUT NOCOPY NUMBER,
              p_batch_id    IN NUMBER,
              p_table_code  IN VARCHAR2,
              p_delete_flag IN VARCHAR2
  );
END igs_en_lgcy_prc;

 

/
