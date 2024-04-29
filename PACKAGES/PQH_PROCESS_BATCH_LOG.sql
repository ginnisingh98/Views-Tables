--------------------------------------------------------
--  DDL for Package PQH_PROCESS_BATCH_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PROCESS_BATCH_LOG" AUTHID CURRENT_USER AS
/* $Header: pqerrlog.pkh 115.4 2003/10/10 05:40:28 vevenkat ship $ */

-- record

TYPE t_log_struct_type IS RECORD
( txn_id                 pqh_process_log.txn_id%TYPE,
  txn_table_route_id     pqh_process_log.txn_table_route_id%TYPE,
  level                  NUMBER,
  log_context            pqh_process_log.log_context%TYPE DEFAULT NULL,
  process_log_id         pqh_process_log.process_log_id%TYPE,
  insert_flag            VARCHAR2(10)
);

-- PL/SQL based on the above structure

TYPE t_log_tab IS TABLE OF t_log_struct_type
  INDEX BY BINARY_INTEGER;

-- global variables for the PL/SQL table of record defined above
   g_log_tab    t_log_tab;

-- global variables
  g_batch_id                pqh_process_log.txn_id%TYPE;
  g_module_cd               pqh_process_log.module_cd%TYPE;
  g_master_process_log_id   pqh_process_log.master_process_log_id%TYPE;



PROCEDURE start_log
(
 p_batch_id         IN  pqh_process_log.txn_id%TYPE,
 p_module_cd        IN  pqh_process_log.module_cd%TYPE,
 p_log_context      IN pqh_process_log.log_context%TYPE DEFAULT NULL,
 p_information_category        IN pqh_process_log.information_category%TYPE  DEFAULT NULL,
 p_information1                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information2                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information3                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information4                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information5                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information6                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information7                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information8                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information9                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information10               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information11               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information12               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information13               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information14               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information15               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information16               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information17               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information18               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information19               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information20               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information21               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information22               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information23               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information24               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information25               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information26               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information27               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information28               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information29               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information30               IN pqh_process_log.information1%TYPE  DEFAULT NULL
);

PROCEDURE insert_log
(
 p_message_type_cd             IN pqh_process_log.message_type_cd%TYPE,
 p_message_text                IN pqh_process_log.message_text%TYPE,
 p_information_category        IN pqh_process_log.information_category%TYPE  DEFAULT NULL,
 p_information1                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information2                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information3                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information4                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information5                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information6                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information7                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information8                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information9                IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information10               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information11               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information12               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information13               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information14               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information15               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information16               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information17               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information18               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information19               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information20               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information21               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information22               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information23               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information24               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information25               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information26               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information27               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information28               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information29               IN pqh_process_log.information1%TYPE  DEFAULT NULL,
 p_information30               IN pqh_process_log.information1%TYPE  DEFAULT NULL
);

PROCEDURE set_context_level
(
 p_txn_id               IN pqh_process_log.txn_id%TYPE,
 p_txn_table_route_id   IN pqh_process_log.txn_table_route_id%TYPE,
 p_level                IN NUMBER,
 p_log_context          IN pqh_process_log.log_context%TYPE DEFAULT NULL
);

PROCEDURE end_log ;





END; -- Package Specification PQH_PROCESS_LOG

 

/
