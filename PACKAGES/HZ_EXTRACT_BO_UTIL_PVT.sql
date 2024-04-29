--------------------------------------------------------
--  DDL for Package HZ_EXTRACT_BO_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXTRACT_BO_UTIL_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHEUTVS.pls 120.4.12010000.2 2009/06/25 06:00:24 vsegu ship $ */
/*
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Contact Point
 * @rep:category BUSINESS_ENTITY
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf Oracle Trading Community Architecture Technical Implementation Guide
 */

TYPE BO_ID_TBL IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
G_RETURN_USER_NAME CONSTANT VARCHAR2(255) := NVL(FND_PROFILE.VALUE('HZ_RETURN_USER_NAME'), 'Y'); --8529267


procedure validate_event_id(p_event_id in number,
			    p_party_id in number,
			    p_event_type in varchar2,
			    p_bo_code in varchar2,
			    x_return_status out nocopy varchar2);

FUNCTION get_parent_object_type(
    p_parent_table_name           IN     VARCHAR2,
    p_parent_id             IN     NUMBER
 ) RETURN VARCHAR2;

FUNCTION get_user_name(p_user_id in number) return varchar2;

-- Central procedure for getting root event id.

procedure get_bo_root_ids(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_obj_root_ids        OUT NOCOPY    BO_ID_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

PROCEDURE validate_ssm_id(
  px_id                        IN OUT NOCOPY NUMBER,
  px_os                        IN OUT NOCOPY VARCHAR2,
  px_osr                       IN OUT NOCOPY VARCHAR2,
  p_org_id                     IN            NUMBER := NULL,
  p_obj_type                   IN            VARCHAR2,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2
);


END HZ_EXTRACT_BO_UTIL_PVT;

/
