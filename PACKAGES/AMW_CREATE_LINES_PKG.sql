--------------------------------------------------------
--  DDL for Package AMW_CREATE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_CREATE_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: amwcrlns.pls 120.0 2005/05/31 20:21:55 appldev noship $ */

   PROCEDURE CREATE_LINES (
      P_CHANGE_ID      IN NUMBER
	 ,X_RETURN_STATUS  OUT NOCOPY VARCHAR2
	 ,X_MSG_COUNT      OUT NOCOPY VARCHAR2
	 ,X_MSG_DATA       OUT NOCOPY VARCHAR2
   );

   PROCEDURE CREATE_LINES_RL(
	  P_CHANGE_ID      IN NUMBER
     ,P_PK1            IN NUMBER --PROCESS_ID
	 ,P_PK2            IN NUMBER
	 ,P_PK3            IN NUMBER
	 ,P_PK4            IN NUMBER
	 ,P_PK5            IN NUMBER
	 ,P_ENTITY_NAME    IN VARCHAR2 --AMW_REVISION_ETTY for Risk Library Approvals
	 --02.15.2005 npanandi: added below parameter for ProcessApprovalOption parameter value
     ,p_approval_option in varchar2
   );

   PROCEDURE CREATE_LINES_ORG (
      P_CHANGE_ID      IN NUMBER
     ,P_PK1            IN NUMBER  --PROCESS_ID
     ,P_PK2            IN NUMBER  --ORGANIZATION_ID
     ,P_PK3            IN NUMBER
     ,P_PK4            IN NUMBER
     ,P_PK5            IN NUMBER
     ,P_ENTITY_NAME    IN VARCHAR2 --NAME not yet seeded
     --02.15.2005 npanandi: added below parameter for ProcessApprovalOption parameter value
     ,p_approval_option in varchar2
   );

   ---01.21.2005 NPANANDI: ADDED BELOW PROCEDURE TO CREATE LINE SUBJECTS
   PROCEDURE CREATE_SUBJECT_LINES(
      P_CHANGE_ID      IN NUMBER
     ,P_CHANGE_LINE_ID IN NUMBER
     ,P_ENTITY_NAME    IN VARCHAR2
     --02.03.2005 npanandi: added pk1 to pk5 to populate for Process/Risk/Ctrl Lines
     ,p_pk1_value      in number
     ,p_pk2_value      in number default null
     ,p_pk3_value      in number default null
     ,p_pk4_value      in number default null
     ,p_pk5_value      in number default null
     ,P_SUBJECT_LEVEL  IN NUMBER);

   ---
   ---02.03.2005 npanandi: added below method
   ---
   PROCEDURE CREATE_CHANGE_REQUEST_LINES(
      P_CHANGE_ID      IN NUMBER
     ,p_seq_num_incr   IN NUMBER
     ,p_line_type_id   IN number
     ,p_name           in varchar2
     ,p_description    in varchar2
	 ,x_change_line_id out nocopy number);

   ---
   ---02.16.2005 npanandi: added method to check for and insert
   ---lines of DeleteProcess lineType
   ---
   PROCEDURE process_lines(
      P_CHANGE_ID      IN NUMBER
     ,p_seq_num_incr   in number
     ,p_line_type_id   in number
     ,p_name           in varchar2
     ,p_description    in varchar2
     ,P_ENTITY_NAME1   IN VARCHAR2
     ,P_ENTITY_NAME2   IN VARCHAR2
     ,p_pk1_value      in number
     ,p_pk2_value      in number default null
     ,p_pk3_value      in number default null
	 ,p_pk4_value      in number default null
	 ,p_pk5_value      in number default null);

   --
   --02.15.2004 npanandi: added below function to get lineTypeId
   --given ChangeMgmtTypeCode, EntityName, ParentEntityName
   --
   FUNCTION get_line_type_id(
      p_change_mgmt_type_code IN varchar2
     ,p_entity_name           in varchar2
     ,p_parent_entity_name    IN VARCHAR2) RETURN number;

END AMW_CREATE_LINES_PKG;

 

/
