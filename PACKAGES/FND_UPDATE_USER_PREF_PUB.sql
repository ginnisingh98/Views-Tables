--------------------------------------------------------
--  DDL for Package FND_UPDATE_USER_PREF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_UPDATE_USER_PREF_PUB" AUTHID CURRENT_USER AS
/* $Header: fndpiprs.pls 120.1 2005/07/02 03:35:07 appldev noship $ */

--  Global constants

--  Pre-defined validation levels
--
TYPE preference_rec      IS RECORD
    (
      purpose_code         VARCHAR2(30),
	  purpose_default_code VARCHAR2(10),
	  user_option          VARCHAR2(10));

TYPE preference_tbl   IS TABLE OF preference_rec
                      INDEX BY BINARY_INTEGER;
/* this procedure is used to set the switch of opt-out of all purposes */
PROCEDURE set_donotuse_preference
(  p_api_version     IN  NUMBER,
   p_init_msg_list   IN  VARCHAR2 DEFAULT NULL,
   p_commit          IN  VARCHAR2 DEFAULT NULL,
   p_user_id  	     IN  NUMBER   DEFAULT NULL	,
   p_party_id        IN  NUMBER   DEFAULT NULL,
   x_return_status   OUT NOCOPY   VARCHAR2,
   x_msg_count       OUT NOCOPY   NUMBER,
   x_msg_data        OUT NOCOPY   VARCHAR2
);


/* this procedure is used to set the user to default option for all business purposes */
PROCEDURE set_default_preference
(  p_api_version     IN  NUMBER,
   p_init_msg_list   IN  VARCHAR2 DEFAULT NULL,
   p_commit          IN  VARCHAR2 DEFAULT NULL,
   p_user_id  	     IN  NUMBER   DEFAULT NULL	,
   p_party_id        IN  NUMBER   DEFAULT NULL,
   x_return_status   OUT NOCOPY   VARCHAR2,
   x_msg_count       OUT NOCOPY   NUMBER,
   x_msg_data        OUT NOCOPY   VARCHAR2
);

/* this procedure is used to individually opt-in /opt-out of business purposes */
PROCEDURE set_purpose_option
(  p_api_version     IN  NUMBER,
   p_init_msg_list   IN  VARCHAR2 DEFAULT NULL,
   p_commit          IN  VARCHAR2 DEFAULT NULL,
   p_user_id  	     IN  NUMBER   DEFAULT NULL	,
   p_party_id        IN  NUMBER   DEFAULT NULL	,
   p_option          IN  preference_tbl ,
   x_return_status   OUT NOCOPY   VARCHAR2,
   x_msg_count       OUT NOCOPY   NUMBER,
   x_msg_data        OUT NOCOPY   VARCHAR2
);


END FND_UPDATE_USER_PREF_PUB;

 

/
