--------------------------------------------------------
--  DDL for Package Body IEX_DUNNINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_DUNNINGS_PKG" AS
/* $Header: iextdunb.pls 120.8.12010000.5 2010/02/05 12:40:16 gnramasa ship $ */

     PG_DEBUG NUMBER(2) ;

PROCEDURE insert_row(
          px_rowid                          IN OUT NOCOPY VARCHAR2
        , px_dunning_id                     IN OUT NOCOPY NUMBER
        , p_template_id                      NUMBER
        , p_callback_yn                      VARCHAR2
        , p_callback_date                    DATE
        , p_campaign_sched_id                NUMBER
        , p_status                           VARCHAR2
        , p_delinquency_id                   NUMBER
        , p_ffm_request_id                   NUMBER
        , p_xml_request_id                   NUMBER
        , p_xml_template_id                  NUMBER
        , p_object_id                        NUMBER
        , p_object_type                      VARCHAR2
        , p_dunning_object_id                NUMBER
        , p_dunning_level                    VARCHAR2
        , p_dunning_method                   VARCHAR2
        , p_amount_due_remaining             NUMBER
        , p_currency_code                    VARCHAR2
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
	, p_request_id                       NUMBER   -- Added for bug 5661324 by gnramasa 14-Mar-07
        , p_financial_charge                 NUMBER
        , p_letter_name                      VARCHAR2
        , p_interest_amt                     NUMBER
        , p_dunning_plan_id                  NUMBER
        , p_contact_destination              varchar2
        , p_contact_party_id                 NUMBER
	, p_delivery_status                  varchar2  -- Added for bug 5661324 by gnramasa 14-Mar-07
        , p_parent_dunning_id                number    -- Added for bug 5661324 by gnramasa 14-Mar-07
	, p_dunning_mode		     varchar2  -- added by gnramasa for bug 8489610 14-May-09
	, p_confirmation_mode                varchar2  -- added by gnramasa for bug 8489610 14-May-09
	, p_org_id                           number    -- added for bug 9151851 PNAVEENK
	, p_ag_dn_xref_id                    number
	, p_correspondence_date              date
     ) IS
        CURSOR l_insert IS
          SELECT ROWID
            FROM iex_dunnings
           WHERE dunning_id = px_dunning_id;
        --
        CURSOR get_seq_csr is
          SELECT IEX_dunnings_s.nextval
            FROM sys.dual;
     BEGIN
     --
        If (px_dunning_id IS NULL) OR (px_dunning_id = FND_API.G_MISS_NUM) then
            OPEN get_seq_csr;
            FETCH get_seq_csr INTO px_dunning_id;
            CLOSE get_seq_csr;
        End If;
        --Start adding for bug 8489610 by gnramasa 14-May-09
	--
        INSERT INTO IEX_DUNNINGS (
          DUNNING_ID
        , TEMPLATE_ID
        , CALLBACK_YN
        , CALLBACK_DATE
        , CAMPAIGN_SCHED_ID
        , STATUS
        , DELINQUENCY_ID
        , FFM_REQUEST_ID
        , XML_REQUEST_ID
        , XML_TEMPLATE_ID
        , OBJECT_ID
        , OBJECT_TYPE
        , DUNNING_OBJECT_ID
        , DUNNING_LEVEL
        , DUNNING_METHOD
        , AMOUNT_DUE_REMAINING
        , CURRENCY_CODE
        , last_update_date
        , last_updated_by
        , creation_date
        , created_by
        , last_update_login
	, request_id
        , financial_charge
        , letter_name
        , interest_amt
        , dunning_plan_id
        , contact_destination
        , contact_party_id
	, delivery_status
        , parent_dunning_id
	, dunning_mode
	, confirmation_mode
	, org_id  -- added for bug 9151851
	, ag_dn_xref_id
	, correspondence_date
        ) VALUES (
          px_dunning_id
        , DECODE(p_template_id, FND_API.G_MISS_NUM, NULL, p_template_id)
        , DECODE(p_callback_YN, FND_API.G_MISS_CHAR, NULL, p_callback_YN)
        , DECODE(p_callback_date, FND_API.G_MISS_DATE, NULL, p_callback_date)
        , DECODE(p_campaign_sched_id, FND_API.G_MISS_NUM, NULL, p_campaign_sched_id)
        , DECODE(p_status, FND_API.G_MISS_CHAR, NULL, p_status)
        , DECODE(p_delinquency_id, FND_API.G_MISS_NUM, NULL, p_delinquency_id)
        , DECODE(p_ffm_request_id, FND_API.G_MISS_NUM, NULL, p_ffm_request_id)
        , DECODE(p_xml_request_id, FND_API.G_MISS_NUM, NULL, p_xml_request_id)
        , DECODE(p_xml_template_id, FND_API.G_MISS_NUM, NULL, p_xml_template_id)
        , DECODE(p_object_id, FND_API.G_MISS_NUM, NULL, p_object_id)
        , DECODE(p_object_type, FND_API.G_MISS_CHAR, NULL, p_object_type)
        , DECODE(p_dunning_object_id, FND_API.G_MISS_NUM, NULL, p_dunning_object_id)
        , DECODE(p_dunning_level, FND_API.G_MISS_CHAR, NULL, p_dunning_level)
        , DECODE(p_dunning_method, FND_API.G_MISS_CHAR, NULL, p_dunning_method)
        , DECODE(p_amount_due_remaining, FND_API.G_MISS_NUM, NULL, p_amount_due_remaining)
        , DECODE(p_currency_code, FND_API.G_MISS_CHAR, NULL, p_currency_code)
        , DECODE(p_last_update_date, FND_API.G_MISS_DATE, TO_DATE(NULL), p_last_update_date)
        , DECODE(p_last_updated_by, FND_API.G_MISS_NUM, NULL, p_last_updated_by)
        , DECODE(p_creation_date, FND_API.G_MISS_DATE, TO_DATE(NULL), p_creation_date)
        , DECODE(p_created_by, FND_API.G_MISS_NUM, NULL, p_created_by)
        , DECODE(p_last_update_login, FND_API.G_MISS_NUM, NULL, p_last_update_login)
	, DECODE(p_request_id, FND_API.G_MISS_NUM, NULL, p_request_id)
        , DECODE(p_financial_charge, FND_API.G_MISS_NUM, NULL, p_financial_charge)
        , DECODE(p_letter_name, FND_API.G_MISS_CHAR, NULL, p_letter_name)
        , DECODE(p_interest_amt, FND_API.G_MISS_NUM, NULL, p_interest_amt)
        , DECODE(p_dunning_plan_id, FND_API.G_MISS_NUM, NULL, p_dunning_plan_id)
        , DECODE(p_contact_destination, FND_API.G_MISS_CHAR, NULL, p_contact_destination)
        , DECODE(p_contact_party_id, FND_API.G_MISS_NUM, NULL, p_contact_party_id)
	, DECODE(p_delivery_status, FND_API.G_MISS_CHAR, NULL, p_delivery_status)
        , DECODE(p_parent_dunning_id, FND_API.G_MISS_NUM, NULL, p_parent_dunning_id)
	, DECODE(p_dunning_mode, FND_API.G_MISS_CHAR, NULL, p_dunning_mode)
	, DECODE(p_confirmation_mode, FND_API.G_MISS_CHAR, NULL, p_confirmation_mode)
	, DECODE(p_org_id, FND_API.G_MISS_NUM, NULL, p_org_id) -- added for bug 9151851
	, DECODE(p_ag_dn_xref_id, FND_API.G_MISS_NUM, NULL, p_ag_dn_xref_id)
	, DECODE(p_correspondence_date, FND_API.G_MISS_DATE, TO_DATE(NULL), p_correspondence_date)
        );

        OPEN l_insert;
        FETCH l_insert INTO px_rowid;
        IF (l_insert%NOTFOUND) THEN
            CLOSE l_insert;
            RAISE NO_DATA_FOUND;
        END IF;
     END insert_row;



     PROCEDURE delete_row(
        p_dunning_id                     NUMBER
     ) IS
     BEGIN
        DELETE FROM iex_dunnings
        WHERE dunning_id = p_dunning_id;
        IF (SQL%NOTFOUND) THEN
            RAISE NO_DATA_FOUND;
        END IF;
     END delete_row;


     PROCEDURE update_row(
          p_rowid                            VARCHAR2
        , p_dunning_id                       NUMBER
        , p_template_id                      NUMBER
        , p_callback_yn                      VARCHAR2
        , p_callback_date                    DATE
        , p_campaign_sched_id                NUMBER
        , p_status                           VARCHAR2
        , p_delinquency_id                   NUMBER
        , p_ffm_request_id                   NUMBER
        , p_xml_request_id                   NUMBER
        , p_xml_template_id                  NUMBER
        , p_object_id                        NUMBER
        , p_object_type                      VARCHAR2
        , p_dunning_object_id                NUMBER
        , p_dunning_level                    VARCHAR2
        , p_dunning_method                   VARCHAR2
        , p_amount_due_remaining             NUMBER
        , p_currency_code                    VARCHAR2
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
        , p_request_id                       NUMBER
	, p_financial_charge                 NUMBER
        , p_letter_name                      VARCHAR2
        , p_interest_amt                     NUMBER
        , p_dunning_plan_id                  NUMBER
        , p_contact_destination              varchar2
        , p_contact_party_id                 NUMBER
	, p_delivery_status                  varchar2
        , p_parent_dunning_id                number
	, p_dunning_mode		     varchar2  -- added by gnramasa for bug 8489610 14-May-09
	, p_confirmation_mode                varchar2  -- added by gnramasa for bug 8489610 14-May-09
	, p_ag_dn_xref_id                    number
	, p_correspondence_date              date
     ) IS
     BEGIN
        UPDATE iex_dunnings
        SET
          dunning_id        = DECODE(p_dunning_id, FND_API.G_MISS_NUM, NULL, p_dunning_id)
        , template_id       = DECODE(p_template_id, FND_API.G_MISS_NUM, NULL, p_template_id)
        , callback_yn       = DECODE(p_callback_yn, FND_API.G_MISS_CHAR, NULL, p_callback_yn)
        , callback_date     = DECODE(p_callback_date, FND_API.G_MISS_DATE, NULL, p_callback_date)
        , campaign_sched_id = DECODE(p_campaign_sched_id, FND_API.G_MISS_NUM, NULL, p_campaign_sched_id)
        , status            = DECODE(p_status, FND_API.G_MISS_CHAR, NULL, p_status)
        , delinquency_id    = DECODE(p_delinquency_id, FND_API.G_MISS_NUM, NULL, p_delinquency_id)
        , ffm_request_id    = DECODE(p_ffm_request_id, FND_API.G_MISS_NUM, NULL, p_ffm_request_id)
        , xml_request_id    = DECODE(p_xml_request_id, FND_API.G_MISS_NUM, NULL, p_xml_request_id)
        , xml_template_id   = DECODE(p_xml_template_id, FND_API.G_MISS_NUM, NULL, p_xml_template_id)
        , object_id         = DECODE(p_object_id, FND_API.G_MISS_NUM, NULL, p_object_id)
        , object_type       = DECODE(p_object_type, FND_API.G_MISS_CHAR, NULL, p_object_type)
        , dunning_object_id = DECODE(p_dunning_object_id, FND_API.G_MISS_NUM, NULL, p_dunning_object_id)
        , dunning_level     = DECODE(p_dunning_level, FND_API.G_MISS_CHAR, NULL, p_dunning_level)
        , dunning_method    = DECODE(p_dunning_method, FND_API.G_MISS_CHAR, NULL, p_dunning_method)
        , amount_due_remaining = DECODE(p_amount_due_remaining, FND_API.G_MISS_NUM, NULL, p_amount_due_remaining)
        , currency_code     = DECODE(p_currency_code, FND_API.G_MISS_CHAR, NULL, p_currency_code)
        , last_update_date  = DECODE(p_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),p_last_update_date)
        , last_updated_by   = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,NULL,p_last_updated_by)
        , creation_date     = DECODE(p_creation_date,FND_API.G_MISS_DATE,TO_DATE(NULL),p_creation_date)
        , created_by        = DECODE(p_created_by,FND_API.G_MISS_NUM,NULL,p_created_by)
        , last_update_login = DECODE(p_last_update_login,FND_API.G_MISS_NUM,NULL,p_last_update_login)
	, request_id        = DECODE(p_request_id,FND_API.G_MISS_NUM,NULL,p_request_id)
        , financial_charge  = DECODE(p_financial_charge, FND_API.G_MISS_NUM, NULL, p_financial_charge)
        , letter_name       = DECODE(p_letter_name, FND_API.G_MISS_CHAR, NULL, p_letter_name)
        , interest_amt      = DECODE(p_interest_amt, FND_API.G_MISS_NUM, NULL, p_interest_amt)
        , dunning_plan_id   = DECODE(p_dunning_plan_id, FND_API.G_MISS_NUM, NULL, p_dunning_plan_id)
        , contact_destination   = DECODE(p_contact_destination, FND_API.G_MISS_CHAR, NULL, p_contact_destination)
        , contact_party_id   = DECODE(p_contact_party_id, FND_API.G_MISS_NUM, NULL, p_contact_party_id)
	, delivery_status   = DECODE(p_delivery_status, FND_API.G_MISS_CHAR, NULL, p_delivery_status)
        , parent_dunning_id = DECODE(p_parent_dunning_id, FND_API.G_MISS_NUM, NULL, p_parent_dunning_id)
	, dunning_mode      = DECODE(p_dunning_mode, FND_API.G_MISS_CHAR, NULL, p_dunning_mode)
	, confirmation_mode = DECODE(p_confirmation_mode, FND_API.G_MISS_CHAR, NULL, p_confirmation_mode)
	, ag_dn_xref_id     = DECODE(p_ag_dn_xref_id, FND_API.G_MISS_NUM, NULL, p_ag_dn_xref_id)
	, correspondence_date = DECODE(p_correspondence_date,FND_API.G_MISS_DATE,TO_DATE(NULL),p_correspondence_date)
        WHERE ROWID         = p_rowid;
        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
	--End adding for bug 8489610 by gnramasa 14-May-09
     END update_row;



     PROCEDURE lock_row(
          p_rowid                            VARCHAR2
        , p_dunning_id                       NUMBER
        , p_template_id                      NUMBER
        , p_callback_yn                      VARCHAR2
        , p_callback_date                    DATE
        , p_campaign_sched_id                NUMBER
        , p_status                           VARCHAR2
        , p_delinquency_id                   NUMBER
        , p_ffm_request_id                   NUMBER
        , p_xml_request_id                   NUMBER
        , p_xml_template_id                  NUMBER
        , p_object_id                        NUMBER
        , p_object_type                      VARCHAR2
        , p_dunning_object_id                NUMBER
        , p_dunning_level                    VARCHAR2
        , p_dunning_method                   VARCHAR2
        , p_amount_due_remaining             NUMBER
        , p_currency_code                    VARCHAR2
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
        , p_financial_charge                 NUMBER
        , p_letter_name                      VARCHAR2
        , p_interest_amt                     NUMBER
        , p_dunning_plan_id                  NUMBER
        , p_contact_destination              varchar2
        , p_contact_party_id                 NUMBER
     ) IS
        CURSOR l_lock IS
          SELECT *
          FROM iex_dunnings
          WHERE rowid = p_rowid
          FOR UPDATE OF dunning_id NOWAIT;
        l_table_rec l_lock%ROWTYPE;
     BEGIN
        OPEN l_lock;
        FETCH l_lock INTO l_table_rec;
        IF (l_lock%NOTFOUND) THEN
             CLOSE l_lock;
             FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
             APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
        CLOSE l_lock;
        IF (
          ((l_table_rec.dunning_id = p_dunning_id)
            OR ((l_table_rec.dunning_id IS NULL)
                AND ( p_dunning_id IS NULL)))
          AND           ((l_table_rec.template_id = p_template_id)
            OR ((l_table_rec.template_id IS NULL)
                AND ( p_template_id IS NULL)))
          AND		((l_table_rec.callback_yn = p_callback_yn)
            OR ((l_table_rec.callback_yn IS NULL)
                AND ( p_callback_yn IS NULL)))
          AND		((l_table_rec.callback_date = p_callback_date)
            OR ((l_table_rec.callback_date IS NULL)
                AND ( p_callback_date IS NULL)))
          AND		((l_table_rec.campaign_sched_id = p_campaign_sched_id)
            OR ((l_table_rec.campaign_sched_id IS NULL)
                AND ( p_campaign_sched_id IS NULL)))
          AND		((l_table_rec.status = p_status)
            OR ((l_table_rec.status IS NULL)
                AND ( p_status IS NULL)))
          AND		((l_table_rec.delinquency_id = p_delinquency_id)
            OR ((l_table_rec.delinquency_id IS NULL)
                AND ( p_delinquency_id IS NULL)))
          AND		((l_table_rec.ffm_request_id = p_ffm_request_id)
            OR ((l_table_rec.ffm_request_id IS NULL)
                AND ( p_ffm_request_id IS NULL)))
          AND		((l_table_rec.xml_request_id = p_xml_request_id)
            OR ((l_table_rec.xml_request_id IS NULL)
                AND ( p_xml_request_id IS NULL)))
          AND		((l_table_rec.xml_template_id = p_xml_template_id)
            OR ((l_table_rec.xml_template_id IS NULL)
                AND ( p_xml_template_id IS NULL)))
          AND		((l_table_rec.object_id = p_object_id)
            OR ((l_table_rec.object_id IS NULL)
                AND ( p_object_id IS NULL)))
          AND		((l_table_rec.object_type = p_object_type)
            OR ((l_table_rec.object_type IS NULL)
                AND ( p_object_type IS NULL)))
          AND		((l_table_rec.dunning_object_id = p_dunning_object_id)
            OR ((l_table_rec.dunning_object_id IS NULL)
                AND ( p_dunning_object_id IS NULL)))
          AND		((l_table_rec.dunning_level = p_dunning_level)
            OR ((l_table_rec.dunning_level IS NULL)
                AND ( p_dunning_level IS NULL)))
          AND		((l_table_rec.dunning_method = p_dunning_method)
            OR ((l_table_rec.dunning_method IS NULL)
                AND ( p_dunning_method IS NULL)))
          AND		((l_table_rec.amount_due_remaining = p_amount_due_remaining)
            OR ((l_table_rec.amount_due_remaining IS NULL)
                AND ( p_amount_due_remaining IS NULL)))
          AND		((l_table_rec.currency_code = p_currency_code)
            OR ((l_table_rec.currency_code IS NULL)
                AND ( p_currency_code IS NULL)))
          AND           ((l_table_rec.last_update_date = p_last_update_date)
            OR ((l_table_rec.last_update_date IS NULL)
                AND ( p_last_update_date IS NULL)))
          AND           ((l_table_rec.last_updated_by = p_last_updated_by)
            OR ((l_table_rec.last_updated_by IS NULL)
                AND ( p_last_updated_by IS NULL)))
          AND           ((l_table_rec.creation_date = p_creation_date)
            OR ((l_table_rec.creation_date IS NULL)
                AND ( p_creation_date IS NULL)))
          AND           ((l_table_rec.created_by = p_created_by)
            OR ((l_table_rec.created_by IS NULL)
                AND ( p_created_by IS NULL)))
          AND           ((l_table_rec.last_update_login = p_last_update_login)
            OR ((l_table_rec.last_update_login IS NULL)
                AND ( p_last_update_login IS NULL)))
          AND           ((l_table_rec.financial_charge = p_financial_charge)
            OR ((l_table_rec.financial_charge IS NULL)
                AND ( p_financial_charge IS NULL)))
          AND           ((l_table_rec.letter_name = p_letter_name)
            OR ((l_table_rec.letter_name IS NULL)
                AND ( p_letter_name IS NULL)))
          AND  ((l_table_rec.interest_amt = p_interest_amt)
            OR ((l_table_rec.interest_amt IS NULL)
                AND ( p_interest_amt IS NULL)))
          AND  ((l_table_rec.dunning_plan_id = p_dunning_plan_id)
            OR ((l_table_rec.dunning_plan_id IS NULL)
                AND ( p_dunning_plan_id IS NULL)))
          AND  ((l_table_rec.contact_destination = p_contact_destination)
            OR ((l_table_rec.contact_destination IS NULL)
                AND ( p_contact_destination IS NULL)))
          AND  ((l_table_rec.contact_party_id = p_contact_party_id)
            OR ((l_table_rec.contact_party_id IS NULL)
                AND ( p_contact_party_id IS NULL)))
        ) THEN
          RETURN;
        ELSE
          FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
     END lock_row;

PROCEDURE insert_Staged_Dunning_row(
          px_rowid                          IN OUT NOCOPY VARCHAR2
        , px_dunning_trx_id                 IN OUT NOCOPY NUMBER
        , p_dunning_id                       NUMBER
        , p_cust_trx_id                      NUMBER
        , p_payment_schedule_id              NUMBER
        , p_ag_dn_xref_id                    NUMBER
        , p_stage_number                     NUMBER
	, p_created_by                       NUMBER
	, p_creation_date                    DATE
	, p_last_updated_by                  NUMBER
        , p_last_update_date                 DATE
        , p_last_update_login                NUMBER
        , p_object_version_number	     NUMBER
     ) IS
        CURSOR l_insert IS
          SELECT ROWID
            FROM iex_dunning_transactions
           WHERE dunning_trx_id = px_dunning_trx_id;
        --
        CURSOR get_seq_csr is
          SELECT iex_dunning_transactions_s.nextval
            FROM sys.dual;
     BEGIN
     --
        If (px_dunning_trx_id IS NULL) OR (px_dunning_trx_id = FND_API.G_MISS_NUM) then
            OPEN get_seq_csr;
            FETCH get_seq_csr INTO px_dunning_trx_id;
            CLOSE get_seq_csr;
        End If;
        --Start adding for bug 8489610 by gnramasa 14-May-09
	--
        INSERT INTO IEX_DUNNING_TRANSACTIONS (
          DUNNING_TRX_ID
	, DUNNING_ID
        , CUST_TRX_ID
        , PAYMENT_SCHEDULE_ID
        , AG_DN_XREF_ID
        , STAGE_NUMBER
        , CREATED_BY
        , CREATION_DATE
        , LAST_UPDATED_BY
        , LAST_UPDATE_DATE
        , LAST_UPDATE_LOGIN
        , OBJECT_VERSION_NUMBER
        ) VALUES (
          px_dunning_trx_id
        , DECODE(p_dunning_id, FND_API.G_MISS_NUM, NULL, p_dunning_id)
        , DECODE(p_cust_trx_id, FND_API.G_MISS_NUM, NULL, p_cust_trx_id)
        , DECODE(p_payment_schedule_id, FND_API.G_MISS_NUM, NULL, p_payment_schedule_id)
        , DECODE(p_ag_dn_xref_id, FND_API.G_MISS_NUM, NULL, p_ag_dn_xref_id)
        , DECODE(p_stage_number, FND_API.G_MISS_NUM, NULL, p_stage_number)
        , DECODE(p_created_by, FND_API.G_MISS_NUM, NULL, p_created_by)
        , DECODE(p_creation_date, FND_API.G_MISS_DATE, NULL, p_creation_date)
        , DECODE(p_last_updated_by, FND_API.G_MISS_NUM, NULL, p_last_updated_by)
        , DECODE(p_last_update_date, FND_API.G_MISS_DATE, NULL, p_last_update_date)
        , DECODE(p_last_update_login, FND_API.G_MISS_NUM, NULL, p_last_update_login)
        , DECODE(p_object_version_number, FND_API.G_MISS_NUM, NULL, p_object_version_number)
        );

        OPEN l_insert;
        FETCH l_insert INTO px_rowid;
        IF (l_insert%NOTFOUND) THEN
            CLOSE l_insert;
            RAISE NO_DATA_FOUND;
        END IF;
END insert_Staged_Dunning_row;

/*
PROCEDURE update_Staged_Dunning_row(
          p_rowid                            VARCHAR2
        , p_dunning_id                       NUMBER
        , p_template_id                      NUMBER
        , p_callback_yn                      VARCHAR2
        , p_callback_date                    DATE
        , p_campaign_sched_id                NUMBER
        , p_status                           VARCHAR2
        , p_delinquency_id                   NUMBER
        , p_ffm_request_id                   NUMBER
        , p_xml_request_id                   NUMBER
        , p_xml_template_id                  NUMBER
        , p_object_id                        NUMBER
        , p_object_type                      VARCHAR2
        , p_dunning_object_id                NUMBER
        , p_dunning_level                    VARCHAR2
        , p_dunning_method                   VARCHAR2
        , p_amount_due_remaining             NUMBER
        , p_currency_code                    VARCHAR2
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
        , p_request_id                       NUMBER
	, p_financial_charge                 NUMBER
        , p_letter_name                      VARCHAR2
        , p_interest_amt                     NUMBER
        , p_dunning_plan_id                  NUMBER
        , p_contact_destination              varchar2
        , p_contact_party_id                 NUMBER
	, p_delivery_status                  varchar2
        , p_parent_dunning_id                number
	, p_dunning_mode		     varchar2  -- added by gnramasa for bug 8489610 14-May-09
	, p_confirmation_mode                varchar2  -- added by gnramasa for bug 8489610 14-May-09
	, p_dunning_plan_line_id             number
     ) IS
     BEGIN
        UPDATE iex_dunnings
        SET
          dunning_id        = DECODE(p_dunning_id, FND_API.G_MISS_NUM, NULL, p_dunning_id)
        , template_id       = DECODE(p_template_id, FND_API.G_MISS_NUM, NULL, p_template_id)
        , callback_yn       = DECODE(p_callback_yn, FND_API.G_MISS_CHAR, NULL, p_callback_yn)
        , callback_date     = DECODE(p_callback_date, FND_API.G_MISS_DATE, NULL, p_callback_date)
        , campaign_sched_id = DECODE(p_campaign_sched_id, FND_API.G_MISS_NUM, NULL, p_campaign_sched_id)
        , status            = DECODE(p_status, FND_API.G_MISS_CHAR, NULL, p_status)
        , delinquency_id    = DECODE(p_delinquency_id, FND_API.G_MISS_NUM, NULL, p_delinquency_id)
        , ffm_request_id    = DECODE(p_ffm_request_id, FND_API.G_MISS_NUM, NULL, p_ffm_request_id)
        , xml_request_id    = DECODE(p_xml_request_id, FND_API.G_MISS_NUM, NULL, p_xml_request_id)
        , xml_template_id   = DECODE(p_xml_template_id, FND_API.G_MISS_NUM, NULL, p_xml_template_id)
        , object_id         = DECODE(p_object_id, FND_API.G_MISS_NUM, NULL, p_object_id)
        , object_type       = DECODE(p_object_type, FND_API.G_MISS_CHAR, NULL, p_object_type)
        , dunning_object_id = DECODE(p_dunning_object_id, FND_API.G_MISS_NUM, NULL, p_dunning_object_id)
        , dunning_level     = DECODE(p_dunning_level, FND_API.G_MISS_CHAR, NULL, p_dunning_level)
        , dunning_method    = DECODE(p_dunning_method, FND_API.G_MISS_CHAR, NULL, p_dunning_method)
        , amount_due_remaining = DECODE(p_amount_due_remaining, FND_API.G_MISS_NUM, NULL, p_amount_due_remaining)
        , currency_code     = DECODE(p_currency_code, FND_API.G_MISS_CHAR, NULL, p_currency_code)
        , last_update_date  = DECODE(p_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),p_last_update_date)
        , last_updated_by   = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,NULL,p_last_updated_by)
        , creation_date     = DECODE(p_creation_date,FND_API.G_MISS_DATE,TO_DATE(NULL),p_creation_date)
        , created_by        = DECODE(p_created_by,FND_API.G_MISS_NUM,NULL,p_created_by)
        , last_update_login = DECODE(p_last_update_login,FND_API.G_MISS_NUM,NULL,p_last_update_login)
	, request_id        = DECODE(p_request_id,FND_API.G_MISS_NUM,NULL,p_request_id)
        , financial_charge  = DECODE(p_financial_charge, FND_API.G_MISS_NUM, NULL, p_financial_charge)
        , letter_name       = DECODE(p_letter_name, FND_API.G_MISS_CHAR, NULL, p_letter_name)
        , interest_amt      = DECODE(p_interest_amt, FND_API.G_MISS_NUM, NULL, p_interest_amt)
        , dunning_plan_id   = DECODE(p_dunning_plan_id, FND_API.G_MISS_NUM, NULL, p_dunning_plan_id)
        , contact_destination   = DECODE(p_contact_destination, FND_API.G_MISS_CHAR, NULL, p_contact_destination)
        , contact_party_id   = DECODE(p_contact_party_id, FND_API.G_MISS_NUM, NULL, p_contact_party_id)
	, delivery_status   = DECODE(p_delivery_status, FND_API.G_MISS_CHAR, NULL, p_delivery_status)
        , parent_dunning_id = DECODE(p_parent_dunning_id, FND_API.G_MISS_NUM, NULL, p_parent_dunning_id)
	, dunning_mode      = DECODE(p_dunning_mode, FND_API.G_MISS_CHAR, NULL, p_dunning_mode)
	, confirmation_mode = DECODE(p_confirmation_mode, FND_API.G_MISS_CHAR, NULL, p_confirmation_mode)
	, dunning_plan_line_id = DECODE(p_dunning_plan_line_id, FND_API.G_MISS_CHAR, NULL, p_dunning_plan_line_id)
        WHERE ROWID         = p_rowid;
        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
	--End adding for bug 8489610 by gnramasa 14-May-09
END update_Staged_Dunning_row;
*/

BEGIN
     PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

END iex_dunnings_pkg;

/
