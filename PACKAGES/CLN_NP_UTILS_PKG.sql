--------------------------------------------------------
--  DDL for Package CLN_NP_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_NP_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: CLNNPUTLS.pls 115.0 2003/10/31 07:20:48 vumapath noship $ */
-- Package
--   CLN_NP_UTILS_PKG
--
-- Purpose
--    Specification of package specification: CLN_NP_UTILS_PKG.
--    This package bundles all the utility functions of
--    notification Processing module for processing inbound messages
--
-- History
--    Oct-16-2003       Viswanthan Umapathy         Created



   -- Name
   --    UPDATE_COLLABORATION
   -- Purpose
   --    This procedure raises collaboration update event to update a collaboration.
   --    passing all the procedure parameters as event parameters
   -- Arguments
   --
   -- Notes
   --    No specific notes.

      PROCEDURE UPDATE_COLLABORATION(
         x_return_status      OUT NOCOPY VARCHAR2,
         x_msg_data           OUT NOCOPY VARCHAR2,
         p_ref_id             IN  VARCHAR2,
         p_doc_no             IN  VARCHAR2,
         p_part_doc_no        IN  VARCHAR2,
         p_msg_text           IN  VARCHAR2,
         p_status_code        IN  NUMBER,
         p_int_ctl_num        IN  NUMBER,
         p_tp_header_id       IN  NUMBER);



   -- Name
   --    ADD_COLLABORATION_MESSAGE
   -- Purpose
   --    This procedure raise event to add messages into collaboration history
   --    passing all the procedure parameters as event parameters
   -- Arguments
   --    Internal Control Number
   --    Reference 1 to 5
   --    Message Text
   -- Notes
   --    No specific notes.

      PROCEDURE ADD_COLLABORATION_MESSAGE(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_ictrl_no                     IN  NUMBER,
         p_ref1                         IN  VARCHAR2,
         p_ref2                         IN  VARCHAR2,
         p_ref3                         IN  VARCHAR2,
         p_ref4                         IN  VARCHAR2,
         p_ref5                         IN  VARCHAR2,
         p_dtl_msg                      IN  VARCHAR2);



   -- Name
   --    GET_FND_MESSSAGE
   -- Purpose
   --    Gets the FND message for the given message name
   --    substituting the token values
   -- Arguments
   --    FND message name
   --    Token Name
   --    Token Value
   -- Notes
   --    No specific notes

      PROCEDURE GET_FND_MESSSAGE(
         p_fnd_message_name IN  VARCHAR2,
         p_token_name1      IN  VARCHAR2,
         p_token_value1     IN  VARCHAR2,
         p_token_name2      IN  VARCHAR2,
         p_token_value2     IN  VARCHAR2,
         p_message          OUT NOCOPY VARCHAR2);



   -- Name
   --   CALL_TAKE_ACTIONS
   -- Purpose
   --   Invokes Notification Processor TAKE_ACTIONS according to the parameter.
   -- Arguments
   -- Notes
   --   No specific notes.

      PROCEDURE CALL_TAKE_ACTIONS(
         p_itemtype        IN VARCHAR2,
         p_itemkey         IN VARCHAR2,
         p_actid           IN NUMBER,
         p_funcmode        IN VARCHAR2,
         x_resultout       IN OUT NOCOPY VARCHAR2);


END CLN_NP_UTILS_PKG;

 

/
