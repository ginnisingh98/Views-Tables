--------------------------------------------------------
--  DDL for Package Body CE_XML_BS_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_XML_BS_LOADER" AS
/* $Header: cexmldrb.pls 120.3 2005/06/24 15:28:13 lkwan noship $      */

  CURSOR get_statements_cursor IS
	select	item_key,
		statement_number,
		trading_partner,
		bank_account_num
        from ce_xml_statement_list;

PROCEDURE SETUP_IMPORT(
		X_STATEMENT_NUMBER	IN	VARCHAR2,
		X_BANK_ACCOUNT_NUM	IN	VARCHAR2,
		X_TRADING_PARTNER	IN	VARCHAR2,
		X_ITEM_KEY		IN	VARCHAR2) IS

BEGIN
    insert into CE_XML_STATEMENT_LIST
	(ITEM_KEY, STATEMENT_NUMBER, TRADING_PARTNER, BANK_ACCOUNT_NUM)
    values (
	X_ITEM_KEY,
	X_STATEMENT_NUMBER,
	X_TRADING_PARTNER,
	X_BANK_ACCOUNT_NUM);
END SETUP_IMPORT;


PROCEDURE RUN_IMPORT IS

  l_statement_number	VARCHAR2(50);
  l_trading_partner	VARCHAR2(50);
  l_bank_account_num	VARCHAR2(50);
  l_item_key		VARCHAR2(20);

  l_cnt			NUMBER;
  l_org_id		NUMBER;
  l_bank_branch_id	NUMBER;
  l_bank_account_id     NUMBER;
  errbuf                VARCHAR2(256);
  retcode               NUMBER;

  l_bs_count		NUMBER;
  l_bs_count2		NUMBER;

BEGIN

  OPEN get_statements_cursor;
  LOOP
    FETCH get_statements_cursor INTO l_item_key,
				l_statement_number,
				l_trading_partner,
				l_bank_account_num;
    EXIT WHEN get_statements_cursor%NOTFOUND OR
              get_statements_cursor%NOTFOUND is null;

    DELETE ce_xml_statement_list
    WHERE  item_key = l_item_key;

    WF_ENGINE.createProcess('CEXMLBSL', l_item_key, 'CE_XML_BSL');

    if (l_trading_partner is null) then
      SELECT count(1)
      INTO   l_cnt
      FROM   CE_BANK_ACCOUNTS
      WHERE  BANK_ACCOUNT_NUM = l_bank_account_num;
    else
      SELECT count(1)
      INTO   l_cnt
      FROM   CE_BANK_ACCOUNTS BA, CE_BANK_BRANCHES_v BB
      WHERE  BA.bank_account_num = l_bank_account_num
      AND    BB.bank_name = l_trading_partner
      AND    BB.branch_party_id = BA.bank_branch_id;
    end if;

    if (l_cnt = 0) then

      /* no bank account id found */
      WF_ENGINE.SetItemAttrNumber(itemtype => 'CEXMLBSL',
				itemkey  => l_item_key,
				aname    => 'CE_IMPORT',
				avalue   => -1);

    elsif (l_cnt > 1) then

      /* multiple bank account id found */
      WF_ENGINE.SetItemAttrNumber(itemtype => 'CEXMLBSL',
				itemkey  => l_item_key,
				aname    => 'CE_IMPORT',
				avalue   => -2);

    else

      /* can run the import program */
      if (l_trading_partner is null) then
        SELECT	BB.branch_party_id,
		BA.bank_account_id,
		BA.ACCOUNT_OWNER_org_id,
		BB.bank_name
	INTO	l_bank_branch_id, l_bank_account_id, l_org_id, l_trading_partner
	FROM	CE_BANK_ACCOUNTS BA, CE_BANK_BRANCHES_V BB
	WHERE	BA.bank_account_num = l_bank_account_num
	AND	BB.branch_party_id = BA.bank_branch_id;
      else
	SELECT	BB.branch_party_id,
		BA.bank_account_id,
		BA.ACCOUNT_OWNER_org_id
	INTO	l_bank_branch_id, l_bank_account_id, l_org_id
	FROM	CE_BANK_ACCOUNTS BA, CE_BANK_BRANCHES_V BB
	WHERE	BA.bank_account_num = l_bank_account_num
	AND	BB.bank_name = l_trading_partner
	AND	BB.branch_party_id = BA.bank_branch_id;
      end if;

      fnd_client_info.set_org_context(l_org_id);

      SELECT count(1)
      INTO   l_bs_count
      FROM   CE_STATEMENT_HEADERS_V
      WHERE  bank_account_id = l_bank_account_id
      AND    statement_number = l_statement_number;

      CE_AUTO_BANK_REC.statement(
        errbuf                  => errbuf,
        retcode                 => retcode,
        p_option                => 'IMPORT',
        p_bank_branch_id        => to_char(l_bank_branch_id),
        p_bank_account_id       => to_char(l_bank_account_id),
        p_statement_number_from => l_statement_number,
        p_statement_number_to   => l_statement_number,
        p_statement_date_from   => '',
        p_statement_date_to     => '',
        p_gl_date      => to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),
        p_receivables_trx_id    => '',
        p_payment_method_id     => '',
        p_nsf_handling          => 'NO_ACTION',
        p_display_debug         => 'N',
        p_debug_path            => '',
        p_debug_file            => '');

      /* check if there is error during import */
      SELECT count(1)
      INTO   l_bs_count2
      FROM   CE_STATEMENT_HEADERS_V
      WHERE  bank_account_id = l_bank_account_id
      AND    statement_number = l_statement_number;

      if (l_bs_count = 0 AND l_bs_count2 = 1) then

        /* no error (or just warning) during import */
        WF_ENGINE.SetItemAttrNumber(itemtype => 'CEXMLBSL',
				itemkey  => l_item_key,
				aname    => 'CE_IMPORT',
				avalue   => 0);

      else

        /* has error during import */
        WF_ENGINE.SetItemAttrNumber(itemtype => 'CEXMLBSL',
				itemkey  => l_item_key,
				aname    => 'CE_IMPORT',
				avalue   => -3);

      end if;

    end if;

    /* set up other WF notification info */
    if (l_trading_partner is null) then
      l_trading_partner := 'unidentified FSP';
    end if;

    WF_ENGINE.SetItemAttrText(itemtype => 'CEXMLBSL',
			itemkey  => l_item_key,
			aname    => 'CE_TRADING_PARTNER',
			avalue   => l_trading_partner);

    WF_ENGINE.SetItemAttrText(itemtype => 'CEXMLBSL',
			itemkey  => l_item_key,
			aname    => 'STATEMENT_NUMBER',
			avalue   => l_statement_number);

    WF_ENGINE.SetItemAttrText(itemtype => 'CEXMLBSL',
			itemkey  => l_item_key,
			aname    => 'CE_NOTIFICATION_ROLE',
			avalue   => 'Cash Management Notifications');

    WF_ENGINE.startProcess('CEXMLBSL', l_item_key);

  END LOOP;
  CLOSE get_statements_cursor;

EXCEPTION
  WHEN OTHERS THEN
    IF get_statements_cursor%ISOPEN THEN
      CLOSE get_statements_cursor;
    END IF;
    RAISE;
END RUN_IMPORT;

END CE_XML_BS_LOADER;

/
