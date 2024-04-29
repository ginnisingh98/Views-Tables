--------------------------------------------------------
--  DDL for Package Body ENG_ICMDB_APIS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_ICMDB_APIS_UTIL" AS
/* $Header: ENGUICMB.pls 120.3 2006/11/08 08:24:00 asjohal noship $ */


        PLSQL_COMPILE_ERROR EXCEPTION;
        PRAGMA EXCEPTION_INIT(PLSQL_COMPILE_ERROR, -6550);

PROCEDURE create_lines(
                     p_change_id in number,
                     x_return_status out nocopy varchar2,
                     x_msg_count out nocopy number,
                     x_msg_data out nocopy varchar2) IS

l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_pls_block          VARCHAR2(5000);

BEGIN

         l_pls_block :=    ' BEGIN '
                        || '  amw_create_lines_pkg.create_lines '
                        || '  ( p_change_id   => :a             '
                        || '   ,x_return_status  => :b          '
                        || '   ,x_msg_count =>:c                '
                        || '   ,x_msg_data => :d                '
                        || ' ); '
                        || ' END; ';

    EXECUTE IMMEDIATE l_pls_block USING
             p_change_id,
             OUT l_return_status,
             OUT l_msg_count,
             OUT l_msg_data;


    x_return_status := l_return_status;
    x_msg_count := l_msg_count;
    x_msg_data := l_msg_data;



EXCEPTION
    WHEN PLSQL_COMPILE_ERROR THEN
        -- Assuming AMW is not installed
        x_return_status := NULL;
        x_msg_count := 0;
        x_msg_data := NULL;


   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Add_Exc_Msg
        ( p_pkg_name            => 'AMW_CM_EVENT_LISTNER_PKG' ,
          p_procedure_name      => 'UPDATE_APPROVAL_STATUS',
          p_error_text          => Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)
        );


        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count ,
          p_data  => x_msg_data
        );

END create_lines ;


PROCEDURE update_approval_status(
                     p_change_id IN NUMBER,
                     p_base_change_mgmt_type_code  IN VARCHAR2 ,
                     p_new_approval_status_cde IN NUMBER ,
                     p_workflow_status_code IN VARCHAR2,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count OUT NOCOPY NUMBER,
                     x_msg_data OUT NOCOPY VARCHAR2)
IS

l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_pls_block          VARCHAR2(5000);

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    l_pls_block :=    ' BEGIN '
                        || '  AMW_CM_EVENT_LISTNER_PKG.UPDATE_APPROVAL_STATUS'
                        || '  ( p_change_id   => :a '
                        || '   ,p_base_change_mgmt_type_code => :b '
                        || '   ,p_new_approval_status_code   => :c '
                        || '   ,p_workflow_status_code   => :d '
                        || '   ,x_return_status  => :e '
                        || '   ,x_msg_count =>:f '
                        || '   ,x_msg_data => :g '
                        || ' ); '
                        || ' END; ';

    EXECUTE IMMEDIATE l_pls_block USING
             p_change_id,
             p_base_change_mgmt_type_code,
             p_new_approval_status_cde,
             p_workflow_status_code,
             OUT l_return_status,
             OUT l_msg_count,
             OUT l_msg_data;


    x_return_status := l_return_status;
    x_msg_count := l_msg_count;
    x_msg_data := l_msg_data;

EXCEPTION
    WHEN PLSQL_COMPILE_ERROR THEN
        -- Assuming AMW is not installed
        x_return_status := NULL;
        x_msg_count := 0;
        x_msg_data := NULL;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Add_Exc_Msg
        ( p_pkg_name            => 'AMW_CM_EVENT_LISTNER_PKG' ,
          p_procedure_name      => 'UPDATE_APPROVAL_STATUS',
          p_error_text          => Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)
        );


        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count ,
          p_data  => x_msg_data
        );

END update_approval_status;



END ENG_ICMDB_APIS_UTIL;

/
