--------------------------------------------------------
--  DDL for Package Body IEU_NONMEDIA_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_NONMEDIA_ACTION_PVT" AS
/* $Header: IEUNMAB.pls 115.0 2003/08/25 16:17:53 gpagadal noship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          IEU_NonMedia_Action_PVT
-- Purpose
--    To provide easy to use apis for Nonmedia action admin.
-- History
--    22-Aug-2003     gpagadal    Created.
-- NOTE
--
-- End of Comments
-- ===============================================================
PROCEDURE Create_NMediaAction(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_docname IN VARCHAR2,
                       p_resp_id IN NUMBER,
                       p_tflag IN VARCHAR2,
                       p_mdef_id IN NUMBER
                       )as
    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_nmedia_id  IEU_UWQ_NONMEDIA_ACTIONS.NONMEDIA_ACTION_ID%type;
    l_temp_str varchar2(80);

BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';
    x_msg_count := 0;
    l_temp_str := null;


    select IEU_UWQ_NONMEDIA_ACTIONS_S1.nextval into l_nmedia_id from dual;

    EXECUTE immediate 'INSERT INTO  IEU_UWQ_NONMEDIA_ACTIONS '||
    '(   NONMEDIA_ACTION_ID, ' ||
    '    CREATED_BY, ' ||
    '    CREATION_DATE, ' ||
    '    LAST_UPDATED_BY,' ||
    '    LAST_UPDATE_DATE, ' ||
    '    LAST_UPDATE_LOGIN, ' ||
    '    ACTION_OBJECT_CODE, ' ||
    '    MACTION_DEF_ID, ' ||
    '    APPLICATION_ID, ' ||
    '    RESPONSIBILITY_ID, ' ||
    '    SOURCE_FOR_TASK_FLAG, ' ||
    '  OBJECT_VERSION_NUMBER,' ||
    '  SECURITY_GROUP_ID ' ||
    ' )VALUES ' ||
    '(:1 ,' ||
    ' :2, '||
    ' :3, '||
    ' :4, '||
    ' :5, '||
    ' :6, '||
    ' :7, '||
    ' :8, '||
    ' :9, '||
    ' :10, '||
    ' :11, '||
    ' :12, '||
    ' :13 '||
    ') '
     USING  l_nmedia_id,
       FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.LOGIN_ID,
        LTRIM(RTRIM(p_docname)),
        p_mdef_id,
        696,
        p_resp_id,
        p_tflag,
        0,
        0;

COMMIT;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

END Create_NMediaAction;


PROCEDURE Update_NMediaAction(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_nmedia_id IN NUMBER,
                       p_docname IN VARCHAR2,
                       p_resp_id IN NUMBER,
                       p_tflag IN VARCHAR2,
                       p_mdef_id IN NUMBER
                       )as
    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_nmedia_id  IEU_UWQ_NONMEDIA_ACTIONS.NONMEDIA_ACTION_ID%type;
    l_temp_str varchar2(80);

BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';
    x_msg_count := 0;
    l_temp_str := null;


        update IEU_UWQ_NONMEDIA_ACTIONS set
            LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
            MACTION_DEF_ID = p_mdef_id,
            RESPONSIBILITY_ID = p_resp_id,
            SOURCE_FOR_TASK_FLAG = p_tflag,
            ACTION_OBJECT_CODE= p_docname
         where
          NONMEDIA_ACTION_ID = p_nmedia_id;

         if (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) then


             select IEU_UWQ_NONMEDIA_ACTIONS_S1.nextval into l_nmedia_id from dual;

             EXECUTE immediate 'INSERT INTO  IEU_UWQ_NONMEDIA_ACTIONS '||
             '(   NONMEDIA_ACTION_ID, ' ||
             '    CREATED_BY, ' ||
             '    CREATION_DATE, ' ||
             '    LAST_UPDATED_BY,' ||
             '    LAST_UPDATE_DATE, ' ||
             '    LAST_UPDATE_LOGIN, ' ||
             '    ACTION_OBJECT_CODE, ' ||
             '    MACTION_DEF_ID, ' ||
             '    APPLICATION_ID, ' ||
             '    RESPONSIBILITY_ID, ' ||
             '    SOURCE_FOR_TASK_FLAG, ' ||
             '  OBJECT_VERSION_NUMBER,' ||
             '  SECURITY_GROUP_ID ' ||
             ' )VALUES ' ||
             '(:1 ,' ||
             ' :2, '||
             ' :3, '||
             ' :4, '||
             ' :5, '||
             ' :6, '||
             ' :7, '||
             ' :8, '||
             ' :9, '||
             ' :10, '||
             ' :11, '||
             ' :12, '||
             ' :13 '||
             ') '
              USING  l_nmedia_id,
                FND_GLOBAL.USER_ID,
                 SYSDATE,
                 FND_GLOBAL.USER_ID,
                 SYSDATE,
                 FND_GLOBAL.LOGIN_ID,
                 LTRIM(RTRIM(p_docname)),
                 p_mdef_id,
                 696,
                 p_resp_id,
                 p_tflag,
                 0,
                 0;



         end if;

COMMIT;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

END Update_NMediaAction;

PROCEDURE Delete_NMediaAction(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       x_nmedia_id IN NUMBER
                       )as
    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_nmedia_id  IEU_UWQ_NONMEDIA_ACTIONS.NONMEDIA_ACTION_ID%type;
    l_temp_str varchar2(80);

BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';
    x_msg_count := 0;
    l_temp_str := null;

    EXECUTE immediate
    'delete from IEU_UWQ_NONMEDIA_ACTIONS '||
    ' where  NONMEDIA_ACTION_ID = :1'
    USING x_nmedia_id;

    if (sql%notfound) then
        null;
    end if;

COMMIT;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

END Delete_NMediaAction;

END IEU_NonMedia_Action_PVT;

/
