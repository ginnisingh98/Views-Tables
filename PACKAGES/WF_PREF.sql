--------------------------------------------------------
--  DDL for Package WF_PREF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_PREF" AUTHID CURRENT_USER as
/* $Header: wfprfs.pls 120.1.12010000.3 2009/09/17 08:52:52 skandepu ship $ */
/*#
 * Provides an API to retrieve user preference information.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Preference
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_USER
 * @rep:ihelp FND/@a_pref See the related online help
 */
--
-- EDIT
--   Generate edit preferences page that shows the current values.
-- IN
--
-- NOTE
--
procedure edit (edit_defaults IN VARCHAR2 DEFAULT 'N');

--
-- EDIT
--   Generate edit preferences page that allows you to edit the values
-- IN
--
-- NOTE
--
procedure edit_form (edit_defaults IN VARCHAR2 DEFAULT 'N');

--
-- Lang_LOV
--   Create the data for the Language List of Values
--
procedure Lang_LOV (p_titles_only   IN VARCHAR2 DEFAULT NULL,
                    p_find_criteria IN VARCHAR2 DEFAULT NULL);
--
-- terr_LOV
--   Create the data for the territory List of Values
--
procedure terr_LOV (p_titles_only   IN VARCHAR2 DEFAULT NULL,
                    p_find_criteria IN VARCHAR2 DEFAULT NULL);
--
-- dm_LOV
--   Create the data for the document management home List of Values
--
procedure dm_LOV   (p_titles_only   IN VARCHAR2 DEFAULT NULL,
                    p_find_criteria IN VARCHAR2 DEFAULT NULL);

procedure update_pref (
p_admin_role            IN VARCHAR2  DEFAULT NULL,
p_display_admin_role    IN VARCHAR2  DEFAULT NULL,
p_web_agent             IN VARCHAR2  DEFAULT NULL,
p_edit_defaults         IN VARCHAR2  DEFAULT NULL,
p_language              IN VARCHAR2  DEFAULT NULL,
p_territory             IN VARCHAR2  DEFAULT NULL,
p_date_format           IN VARCHAR2  DEFAULT NULL,
p_dm_node_id            IN VARCHAR2  DEFAULT NULL,
p_dm_home               IN VARCHAR2  DEFAULT NULL,
p_mailtype              IN VARCHAR2  DEFAULT NULL,
p_classid               IN VARCHAR2  DEFAULT NULL,
p_plugin_loc            IN VARCHAR2  DEFAULT NULL,
p_plugin_ver            IN VARCHAR2  DEFAULT NULL,
p_system_guid           IN VARCHAR2  DEFAULT NULL,
p_system_name           IN VARCHAR2  DEFAULT NULL,
p_system_status         IN VARCHAR2  DEFAULT NULL,
p_ldap_host             IN VARCHAR2  DEFAULT NULL,
p_ldap_port             IN VARCHAR2  DEFAULT NULL,
p_ldap_user             IN VARCHAR2  DEFAULT NULL,
p_ldap_opwd             IN VARCHAR2  DEFAULT NULL,
p_ldap_npwd             IN VARCHAR2  DEFAULT NULL,
p_ldap_rpwd             IN VARCHAR2  DEFAULT NULL,
p_ldap_log_base         IN VARCHAR2  DEFAULT NULL,
p_ldap_user_base        IN VARCHAR2  DEFAULT NULL,
p_text_signon           IN VARCHAR2  DEFAULT NULL
);

--update preferences for OAF
procedure update_pref_fwk (
p_admin_role            IN VARCHAR2  DEFAULT NULL,
p_display_admin_role    IN VARCHAR2  DEFAULT NULL,
p_web_agent             IN VARCHAR2  DEFAULT NULL,
p_edit_defaults         IN VARCHAR2  DEFAULT NULL,
p_language              IN VARCHAR2  DEFAULT NULL,
p_territory             IN VARCHAR2  DEFAULT NULL,
p_date_format           IN VARCHAR2  DEFAULT NULL,
p_dm_node_id            IN VARCHAR2  DEFAULT NULL,
p_dm_home               IN VARCHAR2  DEFAULT NULL,
p_mailtype              IN VARCHAR2  DEFAULT NULL,
p_classid               IN VARCHAR2  DEFAULT NULL,
p_plugin_loc            IN VARCHAR2  DEFAULT NULL,
p_plugin_ver            IN VARCHAR2  DEFAULT NULL,
p_system_guid           IN VARCHAR2  DEFAULT NULL,
p_system_name           IN VARCHAR2  DEFAULT NULL,
p_system_status         IN VARCHAR2  DEFAULT NULL,
p_ldap_host             IN VARCHAR2  DEFAULT NULL,
p_ldap_port             IN VARCHAR2  DEFAULT NULL,
p_ldap_user             IN VARCHAR2  DEFAULT NULL,
p_ldap_opwd             IN VARCHAR2  DEFAULT NULL,
p_ldap_npwd             IN VARCHAR2  DEFAULT NULL,
p_ldap_rpwd             IN VARCHAR2  DEFAULT NULL,
p_ldap_log_base         IN VARCHAR2  DEFAULT NULL,
p_ldap_user_base        IN VARCHAR2  DEFAULT NULL,
p_text_signon           IN VARCHAR2  DEFAULT NULL,
p_num_format            IN VARCHAR2  DEFAULT NULL,
p_browser_dll_loc       IN VARCHAR2  DEFAULT NULL,
p_err_msg               OUT NOCOPY VARCHAR2
);

procedure create_reg_button (
when_pressed_url  IN VARCHAR2,
onmouseover       IN VARCHAR2,
icon_top          IN VARCHAR2,
icon_name         IN VARCHAR2,
show_text         IN VARCHAR2);

procedure get_open_lov_window_html;

/*#
 * Retrieves the value of the specified preference for the specified user.
 * Specify -WF_DEFAULT- as the user name to retrieve a global preference value.
 * @param p_user_name Internal Name of the user
 * @param p_preference_name Preference Name
 * @return Preference Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Preference Value
 * @rep:compatibility S
 * @rep:ihelp FND/@a_pref#get_pref See the related online help
 */
FUNCTION get_pref
(
p_user_name        IN  VARCHAR2,
p_preference_name  IN  VARCHAR2
) RETURN VARCHAR2;



-- Bug 8823516 - overriden function of get_pref().
-- Returns the default preference 'MAILHTML' when called by the
-- product team and null for WFDS, if both the user and global
-- preference values are null in FND_USER_PREFERENCES table.
FUNCTION get_pref2
(
p_user_name        IN  VARCHAR2,
p_preference_name  IN  VARCHAR2,
p_caller           IN  VARCHAR2
) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(get_pref2, WNDS, WNPS);

end WF_PREF;

/
