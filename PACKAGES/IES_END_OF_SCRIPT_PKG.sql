--------------------------------------------------------
--  DDL for Package IES_END_OF_SCRIPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_END_OF_SCRIPT_PKG" AUTHID CURRENT_USER AS
/* $Header: ieseoss.pls 115.3 2002/12/09 21:13:14 appldev noship $ */

   PROCEDURE getTemporaryCLOB (panelClob OUT NOCOPY CLOB,
                               questionClob OUT NOCOPY CLOB);


  PROCEDURE insertIESQuestionData
  (
     p_element                        IN     varchar2
  ) ;

  PROCEDURE insertIESPanelData
  (
     p_element                        IN     varchar2
  ) ;

  PROCEDURE insertIESQuestionData
  (
     p_element                        IN     CLOB
  ) ;

  PROCEDURE insertIESPanelData
  (
     p_element                        IN     CLOB
  ) ;

  PROCEDURE updateIESTransactions(interactionId IN NUMBER);


END ies_end_of_script_pkg;

 

/
