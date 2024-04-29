--------------------------------------------------------
--  DDL for Package IGP_WZ_PUBLISH_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGP_WZ_PUBLISH_TEMPLATE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPWZAS.pls 120.0 2005/06/01 20:49:47 appldev noship $ */

/******************************************************************
 Created By         : Prabhat Patel
 Date Created By    : 20-Feb-2004
 Purpose            : Procedures for workflow template approval to publish
 remarks            :
 Change History
 Who      When        What
******************************************************************/

    PROCEDURE submit_approval( p_template_id igp_wz_templates.template_id%TYPE,
                               p_template_name igp_wz_templates.template_name%TYPE,
                               p_user_id    fnd_user.user_id%TYPE);

    PROCEDURE template_preprocess (itemtype       IN              VARCHAR2,
                                 itemkey        IN              VARCHAR2,
                                 actid          IN              NUMBER,
                                 funcmode       IN              VARCHAR2,
                                 resultout      OUT NOCOPY      VARCHAR2);

    PROCEDURE publish_status (itemtype       IN              VARCHAR2,
                              itemkey        IN              VARCHAR2,
                              actid          IN              NUMBER,
                              funcmode       IN              VARCHAR2,
                              resultout      OUT NOCOPY      VARCHAR2);

    PROCEDURE draft_status   (itemtype       IN              VARCHAR2,
                              itemkey        IN              VARCHAR2,
                              actid          IN              NUMBER,
                              funcmode       IN              VARCHAR2,
                              resultout      OUT NOCOPY      VARCHAR2);

    PROCEDURE create_tempdtl_message(
		                      document_id   IN      VARCHAR2,
			                  display_type  IN      VARCHAR2,
                              document      IN OUT NOCOPY CLOB,
                              document_type IN OUT NOCOPY VARCHAR2);

END igp_wz_publish_template_pkg;

 

/
