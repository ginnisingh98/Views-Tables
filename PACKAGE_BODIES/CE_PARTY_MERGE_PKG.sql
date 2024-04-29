--------------------------------------------------------
--  DDL for Package Body CE_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_PARTY_MERGE_PKG" AS
/* $Header: ceptymrb.pls 120.0 2005/09/29 23:42:07 lkwan ship $ */


/* ---------------------------------------------------------------------
|  PROCEDURE								|
|	 bank_merge
|									|
|  CALLS								|
|
|  CALLED BY								|
|	TCA
 --------------------------------------------------------------------- */
PROCEDURE bank_merge(
            p_Entity_name            IN       VARCHAR2,
            p_from_id                IN       NUMBER,
            p_to_id                  IN OUT NOCOPY  NUMBER,
            p_From_FK_id             IN       NUMBER,
            p_To_FK_id               IN       NUMBER,
            p_Parent_Entity_name     IN       VARCHAR2,
            p_batch_id               IN       NUMBER,
            p_Batch_Party_id         IN       NUMBER,
            x_return_status          IN OUT NOCOPY  VARCHAR2    )
 IS

x_party_count	number;
x_bank_count	number;

BEGIN
  FND_FILE.put_line(fnd_file.log,'>> CE_PARTY_MERGE_PKG.bank_merge');

  -- always veto bank for now
  --x_return_status := FND_API.G_RET_STS_SUCCESS;
  fnd_message.set_name('CE','CE_PARTY_BANK_VETO');
  fnd_msg_pub.ADD;
  x_return_status  := fnd_api.g_ret_sts_error ;

/*
  -- If the party is bank, or  clearinghouse
  --  party merge should be veto.


  SELECT count(*)
  INTO  x_party_count
  FROM HZ_PARTY_USG_ASSIGNMENTS
  where  party_id =  p_From_FK_id --p_from_id
  and PARTY_USAGE_CODE in ('BANK', 'CLEARINGHOUSE');

  IF x_party_count > 0 THEN

         fnd_message.set_name('CE','CE_PARTY_BANK_VETO');
         fnd_msg_pub.ADD;
         x_return_status  := fnd_api.g_ret_sts_error ;
    FND_FILE.put_line(fnd_file.log,'return_status: E, CE_PARTY_BANK_VETO ');

  ELSE

    -- check if party_id is defined as a bank in ce_bank_accounts
    SELECT count(*)
    INTO  x_bank_count
    FROM ce_bank_accounts
    where bank_id = p_From_FK_id; --p_from_id;

    IF x_bank_count > 0 THEN

         fnd_message.set_name('CE','CE_PARTY_BANK_VETO');
         fnd_msg_pub.ADD;
         x_return_status  := fnd_api.g_ret_sts_error ;
      FND_FILE.put_line(fnd_file.log,'return_status: E, CE_PARTY_BANK_VETO ');
    END IF;

  END IF;
*/
  FND_FILE.put_line(fnd_file.log,'<< CE_PARTY_MERGE_PKG.bank_merge');

  EXCEPTION
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
       FND_MESSAGE.Set_Token('PROCEDURE', 'CE_PARTY_MERGE_PKG.bank_merge');
       fnd_msg_pub.add;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_FILE.put_line(fnd_file.log,'return_status: U, CE_UNHANDLED_EXCEPTION ');

END bank_merge;

/* ---------------------------------------------------------------------
|  PROCEDURE								|
|	 branch_merge
|									|
|  CALLS								|
|
|  CALLED BY								|
|	TCA
 --------------------------------------------------------------------- */
PROCEDURE branch_merge(
            p_Entity_name            IN       VARCHAR2,
            p_from_id                IN       NUMBER,
            p_to_id                  IN OUT NOCOPY  NUMBER,
            p_From_FK_id             IN       NUMBER,
            p_To_FK_id               IN       NUMBER,
            p_Parent_Entity_name     IN       VARCHAR2,
            p_batch_id               IN       NUMBER,
            p_Batch_Party_id         IN       NUMBER,
            x_return_status          IN OUT NOCOPY  VARCHAR2    )
 IS

x_party_count	number;
x_branch_count	number;

BEGIN
  FND_FILE.put_line(fnd_file.log,'>> CE_PARTY_MERGE_PKG.branch_merge');

  -- always veto branch for now
  --  x_return_status := FND_API.G_RET_STS_SUCCESS;
  fnd_message.set_name('CE','CE_PARTY_BRANCH_VETO');
  fnd_msg_pub.ADD;
  x_return_status  := fnd_api.g_ret_sts_error ;

/*
  -- If the party is bank, bank_branches, clearinghouse or clearinghouse_branch
  --  party merge should be veto.

  SELECT count(*)
  INTO  x_party_count
  FROM HZ_PARTY_USG_ASSIGNMENTS
  where  party_id =  p_From_FK_id  --p_from_id
  and PARTY_USAGE_CODE in ('BANK_BRANCH', 'CLEARINGHOUSE_BRANCH');

  IF x_party_count > 0 THEN

         fnd_message.set_name('CE','CE_PARTY_BRANCH_VETO');
         fnd_msg_pub.ADD;
         x_return_status  := fnd_api.g_ret_sts_error ;
         FND_FILE.put_line(fnd_file.log,'return_status: E, CE_PARTY_BRANCH_VETO ');

  ELSE

    -- check if party_id is defined as a bank branch in ce_bank_accounts
    SELECT count(*)
    INTO  x_branch_count
    FROM ce_bank_accounts
    where bank_branch_id = p_From_FK_id; --p_from_id;

    IF x_branch_count > 0 THEN

         fnd_message.set_name('CE','CE_PARTY_BRANCH_VETO');
         fnd_msg_pub.ADD;
         x_return_status  := fnd_api.g_ret_sts_error ;
         FND_FILE.put_line(fnd_file.log,'return_status: E, CE_PARTY_BRANCH_VETO ');

    END IF;

  END IF;
*/
  FND_FILE.put_line(fnd_file.log,'<< CE_PARTY_MERGE_PKG.branch_merge');

  EXCEPTION
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
       FND_MESSAGE.Set_Token('PROCEDURE', 'CE_PARTY_MERGE_PKG.branch_merge');
       fnd_msg_pub.add;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_FILE.put_line(fnd_file.log,'return_status: U, CE_UNHANDLED_EXCEPTION ');

END branch_merge;


END CE_PARTY_MERGE_PKG;

/
