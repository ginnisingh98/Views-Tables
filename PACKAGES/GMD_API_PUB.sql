--------------------------------------------------------
--  DDL for Package GMD_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_API_PUB" AUTHID CURRENT_USER AS
--$Header: GMDPAPIS.pls 115.2 2003/04/03 13:53:23 hverddin ship $

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDPAPIS.pls                                        |
--| Package Name       : GMD_API_PUB                                         |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains public layer APIs for all other APIs for GMD    |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar	08-Aug-2002	Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments


TYPE number_tab IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;

TYPE gmd_results_tab IS TABLE OF gmd_results%ROWTYPE
   INDEX BY BINARY_INTEGER;

TYPE gmd_spec_results_tab IS TABLE OF gmd_spec_results%ROWTYPE
   INDEX BY BINARY_INTEGER;


PROCEDURE log_message (
   p_message_code   IN   VARCHAR2
  ,p_token1_name    IN   VARCHAR2 := NULL
  ,p_token1_value   IN   VARCHAR2 := NULL
  ,p_token2_name    IN   VARCHAR2 := NULL
  ,p_token2_value   IN   VARCHAR2 := NULL
  ,p_token3_name    IN   VARCHAR2 := NULL
  ,p_token3_value   IN   VARCHAR2 := NULL
  ,p_token4_name    IN   VARCHAR2 := NULL
  ,p_token4_value   IN   VARCHAR2 := NULL
  ,p_token5_name    IN   VARCHAR2 := NULL
  ,p_token5_value   IN   VARCHAR2 := NULL
  ,p_token6_name    IN   VARCHAR2 := NULL
  ,p_token6_value   IN   VARCHAR2 := NULL);


PROCEDURE raise(
P_EVENT_NAME VARCHAR2,
P_EVENT_KEY  VARCHAR2
);


PROCEDURE RAISE2(
P_event_name VARCHAR2,
P_event_key VARCHAR2,
P_Parameter_name1 VARCHAR2,
P_Parameter_value1 VARCHAR2
);

PROCEDURE SET_USER_CONTEXT(
p_user_id        IN NUMBER,
x_return_status  OUT NOCOPY VARCHAR2
);


END GMD_API_PUB;


 

/
