--------------------------------------------------------
--  DDL for Package PA_DISTRIBUTION_LIST_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DISTRIBUTION_LIST_UTILS" AUTHID CURRENT_USER AS
 /* $Header: PATDLUTS.pls 120.1.12010000.4 2009/02/23 22:46:21 asahoo ship $ */
 Function Check_valid_dist_list_id (
                        p_list_id in Number )
 return boolean;

 Function Check_valid_dist_list_item_id (
                        p_list_item_id in Number )
 return varchar2;

 Function Check_dist_list_name_exists (
                        p_list_id   in number default null,
                        p_list_name in varchar2 )
 return boolean;

 --Fix for #Bug 8247832
 Function Check_dist_list_items_exists (
                        p_list_id   in number,
                        p_recipient_type in varchar2,
                        p_recipient_id  in varchar2)
 return boolean;

 Function get_dist_list_id (
                        p_list_name in varchar2 )
 return number;

 Function Check_valid_recipient_type (
                        p_recipient_type in varchar2 )
 return boolean;

 Function Check_valid_recipient_id (
                        p_recipient_type in varchar2,
                        p_recipient_id   in varchar2 )
 return boolean;

 Function Check_valid_access_level (
                        p_access_level in number)
 return boolean;

 Function Check_valid_menu_id (
                        p_menu_id in Number )
 return boolean;

  TYPE PA_VC_1000_150 IS VARRAY(1000) OF VARCHAR2(150);

FUNCTION get_access_level (
  p_object_type        IN   VARCHAR2,
  p_object_id          IN   VARCHAR2,
  p_user_id            IN   NUMBER  DEFAULT FND_GLOBAL.USER_ID,
  x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  p_context_object_type IN  VARCHAR2 DEFAULT NULL,
  p_context_object_id   IN  VARCHAR2 DEFAULT NULL
) RETURN NUMBER;

PROCEDURE get_dist_list (
  p_object_type        IN   VARCHAR2,
  p_object_id          IN   VARCHAR2,
  p_access_level       IN   NUMBER,
  x_user_names         OUT  NOCOPY PA_VC_1000_150, --File.Sql.39 bug 4440895
  x_full_names         OUT  NOCOPY PA_VC_1000_150, --File.Sql.39 bug 4440895
  x_email_addresses    OUT  NOCOPY PA_VC_1000_150, --File.Sql.39 bug 4440895
  x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

/* Added for Bug 6843694 */
PROCEDURE get_dist_list_email (
  p_object_type        IN   VARCHAR2,
  p_object_id          IN   VARCHAR2,
  p_access_level       IN   NUMBER,
  x_user_names         OUT  NOCOPY PA_VC_1000_150,
  x_full_names         OUT  NOCOPY PA_VC_1000_150,
  x_email_addresses    OUT  NOCOPY PA_VC_1000_150,
  x_return_status      OUT  NOCOPY VARCHAR2,
  x_msg_count          OUT  NOCOPY NUMBER,
  x_msg_data           OUT  NOCOPY VARCHAR2
);

PROCEDURE copy_dist_list
 ( p_object_type_from IN VARCHAR2,
   p_object_id_from IN NUMBER,
   p_object_type_to IN VARCHAR2,
   p_object_id_to IN  NUMBER,
   P_CREATED_BY 		in NUMBER default fnd_global.user_id,
   P_CREATION_DATE 	in DATE default sysdate,
   P_LAST_UPDATED_BY 	in NUMBER default fnd_global.user_id,
   P_LAST_UPDATE_DATE 	in DATE default sysdate,
   P_LAST_UPDATE_LOGIN 	in NUMBER default fnd_global.user_id,
   x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );




END  PA_DISTRIBUTION_LIST_UTILS;

/
