--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_MEDIA_CLASS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_MEDIA_CLASS_PVT" AS
-- $Header: IEUMCLB.pls 120.0 2005/06/02 16:00:52 appldev noship $


-- =================================================================
-- Start of Comments
-- Package name
--          IEU_UWQ_MEDIA_CLASS_PVT
-- Purpose
--    To provide easy to use apis for UQW Admin.
-- History
--    25-Oct-2002     gpagadal    Created.
-- NOTE
--
-- End of Comments
-- ==================================================================




--===================================================================
-- NAME
--    GET_MEDIA_CLASS_LIST
--
-- PURPOSE
--    Private api to get all media types.
--
-- NOTES
--    1. UWQ Admin will use this procedure to get all media
--              type classifications
--
--
-- HISTORY
--   25-Oct-2002     GPAGADAL   Created
--   07-Feb-2003     GPAGADAL updated- Change the queryin the procedure so that it
--                   uses cct_classification_values instead of cct view

--====================================================================

PROCEDURE GET_MEDIA_CLASS_LIST (p_media_type_id IN number,
                                p_language IN varchar2,
                                x_media_class_list  OUT NOCOPY SYSTEM.IEU_CLASS_NST
                                )
AS

l_language             VARCHAR2(4);
x_return_status        VARCHAR2(1);


CURSOR c_mclsfn IS
select unique(cv.CLASSIFICATION_VALUE) classification_value, null label
from cct_classification_values cv
order by lower(cv.CLASSIFICATION_VALUE);


   i integer := 0;

BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;

    x_media_class_list := SYSTEM.IEU_CLASS_NST();


    FOR cur_rec IN c_mclsfn
    LOOP

        i := i+1;
        x_media_class_list.EXTEND(1);



        x_media_class_list(x_media_class_list.last) := SYSTEM.IEU_CLASS_OBJ(cur_rec.classification_value, cur_rec.label);

    end LOOP;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        --Rollback to IEU_UWQ_MEDIA_TYPES_PVT;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END GET_MEDIA_CLASS_LIST;

END IEU_UWQ_MEDIA_CLASS_PVT;


/
