--------------------------------------------------------
--  DDL for Package PER_CN_ORG_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CN_ORG_INFO_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: pecnlhoi.pkh 120.0.12010000.1 2008/07/28 04:23:08 appldev ship $ */

PROCEDURE CHECK_CN_ORG_INFO_TYPE_CREATE
        (p_org_info_type_code IN VARCHAR2 --Organization Information type
        ,p_organization_id    IN NUMBER   --Organization ID
        ,p_org_information1   IN VARCHAR2
        ,p_org_information2   IN VARCHAR2
        ,p_org_information3   IN VARCHAR2
        ,p_org_information4   IN VARCHAR2
        ,p_org_information5   IN VARCHAR2
        ,p_org_information6   IN VARCHAR2
        ,p_org_information7   IN VARCHAR2
        ,p_org_information8   IN VARCHAR2
        ,p_org_information9   IN VARCHAR2
        ,p_org_information10  IN VARCHAR2
        ,p_org_information11  IN VARCHAR2
        ,p_org_information12  IN VARCHAR2
        ,p_org_information13  IN VARCHAR2
        ,p_org_information14  IN VARCHAR2
        ,p_org_information15  IN VARCHAR2
        ,p_org_information16  IN VARCHAR2
        ,p_org_information17  IN VARCHAR2
        ,p_org_information18  IN VARCHAR2
        ,p_org_information19  IN VARCHAR2
        ,p_org_information20  IN VARCHAR2
        );

PROCEDURE CHECK_CN_ORG_INFO_TYPE_UPDATE
        (p_org_info_type_code IN VARCHAR2 --Organization Information type
        ,p_org_information_id IN NUMBER   --Organization Information ID
        ,p_org_information1   IN VARCHAR2
        ,p_org_information2   IN VARCHAR2
        ,p_org_information3   IN VARCHAR2
        ,p_org_information4   IN VARCHAR2
        ,p_org_information5   IN VARCHAR2
        ,p_org_information6   IN VARCHAR2
        ,p_org_information7   IN VARCHAR2
        ,p_org_information8   IN VARCHAR2
        ,p_org_information9   IN VARCHAR2
        ,p_org_information10  IN VARCHAR2
        ,p_org_information11  IN VARCHAR2
        ,p_org_information12  IN VARCHAR2
        ,p_org_information13  IN VARCHAR2
        ,p_org_information14  IN VARCHAR2
        ,p_org_information15  IN VARCHAR2
        ,p_org_information16  IN VARCHAR2
        ,p_org_information17  IN VARCHAR2
        ,p_org_information18  IN VARCHAR2
        ,p_org_information19  IN VARCHAR2
        ,p_org_information20  IN VARCHAR2
        );

END per_cn_org_info_leg_hook;

/
