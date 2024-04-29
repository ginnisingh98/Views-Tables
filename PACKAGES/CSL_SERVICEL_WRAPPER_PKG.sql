--------------------------------------------------------
--  DDL for Package CSL_SERVICEL_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_SERVICEL_WRAPPER_PKG" AUTHID CURRENT_USER AS
/* $Header: csllwrps.pls 115.10 2003/03/12 05:15:43 vekrishn ship $ */

 /***
   This function accepts a list of publication items and a publication item
   name and returns whether the item name was found within the item list.
   When the item name was found, it will be removed from the list.
 ***/
 PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name IN VARCHAR2,
           p_tranid   IN NUMBER
         );

 /***
  This function returns a translated error message string. If p_api_error
  is FALSE, it gets message with MESSAGE_NAME = p_message from
  FND_NEW_MESSAGES and replaces any tokens with the supplied token values.
  If p_api_error is TRUE, it just returns the api error in the
  FND_MSG_PUB message stack.
 ***/

 FUNCTION GET_ERROR_MESSAGE_TEXT
         (
           p_api_error      IN BOOLEAN  DEFAULT FALSE
         , p_message        IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE DEFAULT NULL
         , p_token_name1    IN VARCHAR2 DEFAULT NULL
         , p_token_value1   IN VARCHAR2 DEFAULT NULL
         , p_token_name2    IN VARCHAR2 DEFAULT NULL
         , p_token_value2   IN VARCHAR2 DEFAULT NULL
         , p_token_name3    IN VARCHAR2 DEFAULT NULL
         , p_token_value3   IN VARCHAR2 DEFAULT NULL
         )
 RETURN VARCHAR2;

 /***
  This procedure is called by APPLY_CLIENT_CHANGES wrapper procedure when a
  record was successfully applied and needs to be deleted from the in-queue.
 ***/
 PROCEDURE DELETE_RECORD
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_seqno         IN NUMBER,
           p_pk            IN VARCHAR2,
           p_object_name   IN VARCHAR2,
           p_pub_name      IN VARCHAR2,
           p_error_msg     OUT NOCOPY VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

 /***
  This procedure is called by APPLY_CLIENT_CHANGES wrapper procedure
  when a record failed to be processed and needs to be deferred and rejected
  from mobile.
 ***/

 PROCEDURE DEFER_RECORD
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_seqno         IN NUMBER,
           p_pk            IN VARCHAR2,
           p_object_name   IN VARCHAR2,
           p_pub_name      IN VARCHAR2,
           p_error_msg     IN VARCHAR2,
	   x_return_status IN OUT NOCOPY VARCHAR2,
           p_dml_type      IN VARCHAR2 DEFAULT 'I'
         );

 /***
  This procedure gets called when a record needs to be rejected when e.g.
  the api provides its own pk
 ***/

 PROCEDURE REJECT_RECORD
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_seqno         IN NUMBER,
           p_pk            IN VARCHAR2,
           p_object_name   IN VARCHAR2,
           p_pub_name      IN VARCHAR2,
           p_error_msg     IN VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

 /***
  This procedure gets called when a user gets created
 ***/
 PROCEDURE POPULATE_ACCESS_RECORDS ( P_USER_ID IN NUMBER );

 /***
  This procedure gets called when a user gets deleted
 ***/
 PROCEDURE DELETE_ACCESS_RECORDS ( P_USER_ID IN NUMBER );

 /***
  This function returns a boolean if the markdirty is succesfull
  The function is autonomous and commits the markdirty.
 ***/
 FUNCTION AUTONOMOUS_MARK_DIRTY
                       (
                        p_pub_item     IN VARCHAR2,
                        p_accessid     IN NUMBER,
                        p_resourceid   IN NUMBER,
                        p_dml          IN CHAR,
                        p_timestamp    IN DATE
                       )
 RETURN BOOLEAN;

 /***
  Function to Enable Detection of Conflict
 ***/

 FUNCTION DETECT_CONFLICT
                     (
                      p_user_name IN VARCHAR2
                     )
 RETURN VARCHAR2;


 /***
  Function Handler for Resolving Conflicts
 ***/

 FUNCTION CONFLICT_RESOLUTION_HANDLER
                ( p_user_name IN VARCHAR2,
                  p_tran_id IN NUMBER,
                  p_sequence IN NUMBER
                )
 RETURN VARCHAR2;

END CSL_SERVICEL_WRAPPER_PKG;

 

/
