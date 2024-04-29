--------------------------------------------------------
--  DDL for Package IGS_PE_USERID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_USERID_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPE11S.pls 120.4 2006/06/28 12:35:42 gmaheswa ship $ */


FUNCTION  Generate_Username(
 p_subscription_guid	IN	raw,
 p_event		IN OUT NOCOPY	wf_event_t
) return varchar2;

PROCEDURE Create_Batch_Users (errbuf        OUT NOCOPY VARCHAR2,
                              retcode       OUT NOCOPY NUMBER,
                              p_group_id     IN NUMBER,
                              p_org_id       IN VARCHAR2 DEFAULT NULL
);



PROCEDURE Check_Setup
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
);

FUNCTION generate_party_number (
 P_SUBSCRIPTION_GUID	IN	raw,
 P_EVENT		IN OUT NOCOPY	wf_event_t
) RETURN VARCHAR2;

PROCEDURE Create_Party
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
);


PROCEDURE Create_Fnd_User
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
);



PROCEDURE Validate_Username
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
);


PROCEDURE Generate_User
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  x_return_status             OUT NOCOPY      VARCHAR2 ,
  x_msg_count                 OUT NOCOPY      NUMBER   ,
  x_msg_data                  OUT NOCOPY      VARCHAR2 ,
  p_title                     IN       VARCHAR2 ,
  p_number                    IN       VARCHAR2 ,
  p_prefix                    IN       VARCHAR2 ,
  p_alt_id                    IN       VARCHAR2 ,
  p_given_name                IN       VARCHAR2 ,
  p_pref_name                 IN       VARCHAR2 ,
  p_middle_name               IN       VARCHAR2 ,
  p_gender                    IN       VARCHAR2 ,
  p_surname                   IN       VARCHAR2 ,
  p_birth                     IN       VARCHAR2 ,
  p_suffix                    IN       VARCHAR2 ,
  p_user_name                 IN       VARCHAR2 ,
  p_user_password             IN       VARCHAR2 ,
  p_email_format              IN       VARCHAR2 ,
  p_email_address             IN       VARCHAR2
);

FUNCTION get_id_name RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(get_id_name,WNDS,WNPS,RNPS);

FUNCTION generate_password ( p_username IN VARCHAR2) return varchar2;


PROCEDURE Generate_Password
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  x_return_status             OUT NOCOPY      VARCHAR2 ,
  x_msg_count                 OUT NOCOPY      NUMBER   ,
  x_msg_data                  OUT NOCOPY      VARCHAR2 ,
  p_user_name                 IN       VARCHAR2
);

PROCEDURE assign_responsibility
(
  p_person_id NUMBER,
  p_user_id NUMBER
);

FUNCTION umx_business_logic(
 p_subscription_guid IN	RAW,
 p_event	IN OUT NOCOPY WF_EVENT_T
) RETURN VARCHAR2;

PROCEDURE TestUserName
(
  p_user_name		IN       VARCHAR2,
  x_return_status	OUT NOCOPY      VARCHAR2 ,
  x_message_app_name	OUT NOCOPY      VARCHAR2 ,
  x_message_name	OUT NOCOPY      VARCHAR2 ,
  x_message_text	OUT NOCOPY      VARCHAR2
);


PROCEDURE Validate_Person
(
  p_first_name		IN		VARCHAR2,
  p_last_name		IN		VARCHAR2,
  p_birth_date		IN		DATE,
  p_gender		IN		VARCHAR2,
  p_person_num		IN OUT NOCOPY	VARCHAR2,
  p_pref_alt_id		IN		VARCHAR2,
  p_isApplicant		IN		VARCHAR2,
  p_Zipcode		IN  		VARCHAR2,
  p_phoneCountry	IN		VARCHAR2,
  p_phoneArea		IN		VARCHAR2,
  p_phoneNumber		IN		VARCHAR2,
  p_email_address	IN		VARCHAR2,
  x_return_status	OUT NOCOPY      VARCHAR2,
  x_message_name	OUT NOCOPY      VARCHAR2,
  p_person_id		OUT NOCOPY	NUMBER
);

PROCEDURE AUTO_GENERATE_USERNAME
(
  p_user_name		OUT NOCOPY      VARCHAR2 ,
  p_person_number	IN       VARCHAR2,
  p_first_name		IN       VARCHAR2,
  p_last_name		IN       VARCHAR2,
  p_middle_name		IN       VARCHAR2,
  p_pref_name		IN       VARCHAR2,
  p_pref_alt_id		IN       VARCHAR2,
  p_title		IN       VARCHAR2,
  p_prefix		IN       VARCHAR2,
  p_suffix		IN       VARCHAR2,
  p_gender		IN       VARCHAR2,
  p_birth_date		IN	 DATE,
  p_email_address	IN       VARCHAR2,
  p_email_format	IN       VARCHAR2
);

PROCEDURE process_alumni_nomatch_event
(	  itemtype       IN              VARCHAR2,
          itemkey        IN              VARCHAR2,
          actid          IN              NUMBER,
          funcmode       IN              VARCHAR2,
          resultout      OUT NOCOPY      VARCHAR
);

PROCEDURE validate_password
(
  p_user_name		IN		VARCHAR2,
  p_password		IN		VARCHAR2,
  x_return_status	OUT NOCOPY      VARCHAR2 ,
  x_message_text	OUT NOCOPY      VARCHAR2
);

END IGS_PE_USERID_PKG;

 

/
