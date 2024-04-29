--------------------------------------------------------
--  DDL for Package AS_RTTAP_ACCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_RTTAP_ACCOUNT" AUTHID CURRENT_USER AS
/* $Header: asxrtacs.pls 120.2 2005/08/21 09:02:04 subabu noship $ */

FUNCTION CREATE_ORGANIZATION_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2;
FUNCTION UPDATE_ORGANIZATION_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2;
FUNCTION CREATE_PERSON_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2;
FUNCTION UPDATE_PERSON_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2;
FUNCTION CREATE_PARTY_SITE_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2;
FUNCTION UPDATE_PARTY_SITE_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2;
FUNCTION CREATE_CONTACT_POINT_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2;
FUNCTION UPDATE_CONTACT_POINT_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2;
FUNCTION UPDATE_LOCATION_POST ( p_subscription_guid IN RAW, p_event IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2;

PROCEDURE PROCESS_RTTAP_ACCOUNT(
    p_party_Id NUMBER,
    p_return_status OUT NOCOPY VARCHAR2);

PROCEDURE RTTAP_WRAPPER(
    p_party_id IN  NUMBER,
    X_Return_Status OUT NOCOPY  VARCHAR2 );

PROCEDURE EXPLODE_TEAMS_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE EXPLODE_GROUPS_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE SET_TEAM_LEAD_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_ACCESSES_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_TERR_ACCESSES_ACCOUNTS(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE PERFORM_ACCOUNT_CLEANUP(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_WinningTerrMember_tbl     IN OUT NOCOPY  JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type,
    x_return_status    OUT NOCOPY VARCHAR2);
END AS_RTTAP_ACCOUNT;

 

/
