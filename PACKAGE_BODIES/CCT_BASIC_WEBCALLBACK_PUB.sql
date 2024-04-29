--------------------------------------------------------
--  DDL for Package Body CCT_BASIC_WEBCALLBACK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_BASIC_WEBCALLBACK_PUB" AS
/* $Header: cctwebpb.pls 115.1 2004/06/02 22:09:48 edwang noship $ */
    PROCEDURE CCT_BASIC_WEB_ENUM_NODES
    (
        P_RESOURCE_ID IN NUMBER,
        P_LANGUAGE    IN VARCHAR2,
        P_SOURCE_LANG IN VARCHAR2,
        P_SEL_ENUM_ID IN NUMBER
    )
    IS
        l_m_list  IEU_PUB.EnumeratorDataRecordList ;
        l_node_label VARCHAR2(128);
    BEGIN

        SAVEPOINT start_enum ;

        Select meaning into l_node_label
        from fnd_lookup_values_vl
        where lookup_type = 'CCT_SDK_TYPES'
        and lookup_code = 'WEBCALLBACK';

        l_m_list(0).NODE_LABEL := l_node_label ;
        l_m_list(0).VIEW_NAME := 'CCT_BASIC_WEBCALLBACK_V' ;
        l_m_list(0).DATA_SOURCE := 'CCT_BASIC_WEBCALLBACK_DS' ;
        l_m_list(0).MEDIA_TYPE_ID := '20000' ;
        l_m_list(0).WHERE_CLAUSE := '' ;
        l_m_list(0).NODE_TYPE := 0 ;
        l_m_list(0).HIDE_IF_EMPTY := 'N' ;
        l_m_list(0).NODE_DEPTH := 1 ;
        l_m_list(0).BIND_VARS := '' ;
        l_m_list(0).RES_CAT_ENUM_FLAG := 'Y' ;
        l_m_list(0).REFRESH_VIEW_NAME := 'CCT_BASIC_WEBCALLBACK_V' ;
        l_m_list(0).REFRESH_VIEW_SUM_COL := 'QUEUE_COUNT' ; -- Column name

        UPDATE_RT_STATS(P_RESOURCE_ID,0);

        IEU_PUB.ADD_UWQ_NODE_DATA
        (
            P_RESOURCE_ID,
            P_SEL_ENUM_ID,
            l_m_list
        );
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO start_enum ;
        RAISE;
    END CCT_BASIC_WEB_ENUM_NODES;

    PROCEDURE UPDATE_RT_STATS
    (
        P_RESOURCE_ID IN NUMBER,
        P_COUNT       IN NUMBER
    )
    IS
        l_count number ;
    BEGIN

        UPDATE CCT_AGENT_RT_STATS
        SET CLIENT_ID = P_COUNT
        WHERE AGENT_ID = P_RESOURCE_ID;

        IF(SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) THEN
            INSERT INTO CCT_AGENT_RT_STATS
            (
                AGENT_ID,
                CLIENT_ID,
                MCM_ID,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                AGENT_RT_STAT_ID
            )
            VALUES
            (P_RESOURCE_ID,P_COUNT,-1,-1,SYSDATE,-1,SYSDATE,CCT_AGENT_RT_STATS_S.nextval);
        END IF;

    END UPDATE_RT_STATS;



END CCT_BASIC_WEBCALLBACK_PUB;

/
