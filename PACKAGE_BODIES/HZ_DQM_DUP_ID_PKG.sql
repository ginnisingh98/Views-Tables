--------------------------------------------------------
--  DDL for Package Body HZ_DQM_DUP_ID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DQM_DUP_ID_PKG" AS
/* $Header: ARHDUPIB.pls 120.28 2006/07/26 09:04:08 rarajend noship $ */
/*=======================================================================+
 |  Copyright (c) 2003 Oracle Corporation Redwood Shores, California, USA|
 |                          All rights reserved.                         |
 +=======================================================================+
 | NAME
 |      HZ_DQM_DUP_ID_PKG
 |
 | DESCRIPTION
 |      The new system dup identification package, that would identify duplicates, using
 |      B-tree indices.
 |
 |
 | PUBLIC PROCEDURES
 |
 | HISTORY
 |      13-MAY-2003 : VJN Created
 |      7-JUL-2005  Ramesh Ch  Bug No: 4244529.Modified insert stmts to denormalize dup_batch_id
 |                              into hz_dup_set_parties.
 |     18-OCT-2005 Ravi Epuri : Bug No: 4669400. Modified the 2 instances of OPEN pt_cur CURSOR, in tca_dup_id_worker
 |                              Procedure, to make sure it does not consider Merged and Inactive Parties for duplicate
 |                               identification, by adding the filter condition 'Status = A', in the where clause.
 |      12-JUL-2006 : Raj  Bug 5393826: Made changed to procedure report_int_dup_party_osrs.
 |                                      Deleting the records from hz_imp_int_dedup_results for which
 |                                      no records exists in import party interface table.
 |      18-JUL-2006 : Raj Bug 5393863: Made changes to tca_dup_id_worker procedure.
 |                                     Instead of opening a cursor on hz_parties,inserted all the parties in to
 |                                     HZ_MATCHED_PARTIES_GT table and then opened a cursor on HZ_MATCHED_PARTIES_GT table.
 *=======================================================================*/
--check
 -- Definitions:
-- A pair of parties (a,b) denotes two party ids a, b such that
-- b is a duplicate of a, subject to a given match rule.
-- a will be called the source party and b will be called the duplicate party.
-- Given 2 pairs of duplicate parties (a, b) and (c,d), we define the following terms:
-- Identical pairs: a = c and b =d  ex: (1,2) and (1,2)
-- Reversed pairs: a = d and b = c ex: (1,2) and (2,1)
-- Transitive pairs: b = c  ex: (1,2) and (2,3)
-- Indirect Transitives: (a,b) (c,b)
-- Direct Transitives: (a,b) (b,c)
-- Pre Union Phase : The phase before or during the query that does the union of entities.
-- Post Union Phase : The phase after we do the union of entities.
-- Trivial Dup Set: If a party "a" is found as a duplicate of a party "b" adn there are no other duplicates
--                  for either a or b, then the dup set { a, b} will be called a trivial dup set.
--                  These will be of cardinality 2 and they don't need any transitive derivations.
-- Non Trivial Dup Set: These are the ones that have cardinality > 3. For example, let us say, we find the following:
                                                -- 1 duplicate of 2
                                                -- 2 duplicate of 3
                                                -- 2 duplicate of 6
                                                -- 6 duplicate of 5
                                                -- 6 duplicate of 7
                                                -- 6 duplicate of 8
                                                -- 8 duplicate of 12
                                                -- 8 duplicate of 13
                                                -- 13 duplicate of 1
                                                -- 7 duplicate of 0
 --                       The dup set would be  { 1,2,3,5,6,7,8,12,13,0 } after transitive derivations.



------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- TCA DUPLICATE IDENTIFICATION
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


/**
 * PROCEDURE update_hz_dup_results
 *
 * DESCRIPTION
 *
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   04-09-2003  Colathur Vijayan       o Created.
 *
 */

--------------------------------------------------------------------------------------
-- update_hz_dup_results ::: This is a generic procedure, that would do a bulk update
--                           of hz_dup_results, using a passed in open cursor
--------------------------------------------------------------------------------------


PROCEDURE update_hz_dup_results (
    p_cur    IN EntityCur )
is
    l_limit NUMBER := 200;
    l_last_fetch BOOLEAN := FALSE;
    H_FID NumberList;
    H_TID NumberList ;
    H_SCORE NumberList ;

BEGIN

    -- LOOP THROUGH THE PASSED IN OPEN CURSOR
    LOOP
          FETCH p_cur BULK COLLECT INTO
                H_FID
              , H_TID
               ,H_SCORE
          LIMIT l_limit;

          IF p_cur%NOTFOUND THEN
            l_last_fetch:=TRUE;
          END IF;

          IF H_FID.COUNT = 0 and l_last_fetch THEN
            EXIT;
          END IF;

          BEGIN

              FORALL I in H_FID.FIRST..H_FID.LAST
                UPDATE HZ_DUP_RESULTS A
                SET A.SCORE = A.SCORE + H_SCORE(I)
                WHERE
                   ( A.FID = H_FID(I) and
                     A.TID = H_TID(I)
                     );
          END;

          IF l_last_fetch THEN
          EXIT;

          END IF;
    END LOOP;
    ---------- exception block ---------------
    EXCEPTION
    WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
         FND_MESSAGE.SET_TOKEN('PROC','UPDATE_HZ_DUP_RESULTS');
         FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;



PROCEDURE  sanitize_tca_dup_parties (
                p_threshold             IN NUMBER,
                p_auto_merge_threshold  IN NUMBER,
                p_subset_sql            IN VARCHAR2,
                p_within_subset      IN VARCHAR2
)
IS
p_count number ;
BEGIN

        select count(1) into p_count
        from hz_dup_results;

        FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
        FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of parties in HZ_DUP_RESULTS before sanitization '|| p_count );
        FND_FILE.put_line(FND_FILE.log,'Parties ::: Delete based on subset sql');
        FND_FILE.put_line(FND_FILE.log,'Parties ::: Begin time of delete '||to_char(sysdate,'hh24:mi:ss'));




    ----------------------------------------------------------------------------------------------
    -- 1. USE THE SUBSET SQL AND REMOVE ROWS THAT DO NOT QUALIFY.
    -- 2. APPLY THE THRESHOLD AND REMOVE ROWS THAT DON'T SATISFY THRESHOLD.
    -- 3. REMOVE APPROPRIATE ROWS TO MAKE SURE THAT THERE ARE NO REVERSED PAIRS.
    -- 4. REMOVE APPROPRIATE ROWS TO MAKE SURE THAT THERE ARE NO INDIRECT TRANSITIVES.
    ----------------------------------------------------------------------------------------------

    -- The first filter will be on the basis of the subset defined
    -- Filter only if the flag is 'Y' and the subset sql is not null

        IF p_within_subset = 'Y' and p_subset_sql is not null
        THEN
           EXECUTE IMMEDIATE 'delete from hz_dup_results a where ' ||
           'not exists ' ||
           '(Select 1 from hz_dup_results b, hz_parties parties ' ||
           'where b.ord_tid = parties.party_id ' ||
           'and ' ||
           p_subset_sql || ')' ;
         END IF;

   FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
   FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of parties deleted from HZ_DUP_RESULTS '||SQL%ROWCOUNT);
   FND_FILE.put_line(FND_FILE.log,'Parties ::: End time of delete '||to_char(sysdate,'hh24:mi:ss'));

   FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
   FND_FILE.put_line(FND_FILE.log,'Parties ::: Beginning delete on HZ_DUP_RESULTS, based on threshold, reversed pairs and indirect transitives '||SQL%ROWCOUNT);


    -- At the end of this, we would have the following:

    -- Only rows with score >= threshold.
    -- The pair with fid < tid, if both the pairs have the same score.
    -- The pair with the higher score, if in case, the pairs of different scores.


          delete from hz_dup_results a
          where
          -- delete anything less than the threshold
          a.score < p_threshold
          or
          -- if scores are same, delete the one with highest source
          -- or if scores are different, delete the one with lower score
          (exists
            (Select 1 from hz_dup_results b
             where

             (
               (
                -- APPLY THE ABOVE PRINCIPLE TO REVERSED PAIRS
                 a.fid=b.tid and b.fid=a.tid and
                 ( (a.score = b.score and a.fid > b.fid) or (a.score < b.score) )
                )

                or
                -- APPLY THE ABOVE PRINCIPLE TO INDIRECT TRANSITIVES
                ( a.ord_tid=b.ord_tid and ((a.score = b.score and a.ord_fid > b.ord_fid) or (a.score < b.score)) )

             )
          ));

   FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
   FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of parties deleted from HZ_DUP_RESULTS '||SQL%ROWCOUNT);
   FND_FILE.put_line(FND_FILE.log,'Parties ::: End time of delete '||to_char(sysdate,'hh24:mi:ss'));




     ---------- exception block ---------------
        EXCEPTION
        WHEN OTHERS THEN
                 FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
                 FND_MESSAGE.SET_TOKEN('PROC','SANITIZE_TCA_DUP_PARTIES');
                 FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM );
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END;


PROCEDURE update_hz_int_dup_results (
    p_batch_id IN number,
    p_cur    IN EntityCur )
is
    l_limit NUMBER := 200;
    l_last_fetch BOOLEAN := FALSE;
    H_F_OSR CharList;
    H_T_OSR CharList ;
    H_SCORE NumberList ;

BEGIN

    -- LOOP THROUGH THE PASSED IN OPEN CURSOR
    LOOP
          FETCH p_cur BULK COLLECT INTO
                H_F_OSR
              , H_T_OSR
               ,H_SCORE
          LIMIT l_limit;

          IF p_cur%NOTFOUND THEN
            l_last_fetch:=TRUE;
          END IF;

          IF H_F_OSR.COUNT = 0 and l_last_fetch THEN
            EXIT;
          END IF;

          BEGIN

              FORALL I in H_F_OSR.FIRST..H_F_OSR.LAST
                UPDATE HZ_INT_DUP_RESULTS A
                SET A.SCORE = A.SCORE + H_SCORE(I)
                WHERE
                   ( A.F_OSR = H_F_OSR(I) and
                     A.T_OSR = H_T_OSR(I) and
                     A.BATCH_ID = p_batch_id
                     );
          END;

          IF l_last_fetch THEN
          EXIT;

          END IF;
    END LOOP;

      ---------- exception block ---------------
    EXCEPTION
    WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
         FND_MESSAGE.SET_TOKEN('PROC','UPDATE_HZ_INT_DUP_RESULTS');
         FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;



PROCEDURE  sanitize_int_dup_party_osrs (
                p_threshold             IN NUMBER,
                p_batch_id              IN NUMBER
)
IS
l_owner VARCHAR2(30);
p_count number ;
BEGIN

    ----------------------------------------------------------------------------------------------
    -- 1. APPLY THE THRESHOLD AND REMOVE ROWS THAT DON'T SATISFY THRESHOLD.
    -- 2. REMOVE APPROPRIATE ROWS TO MAKE SURE THAT THERE ARE NO REVERSED PAIRS.
    -- 3. REMOVE APPROPRIATE ROWS TO MAKE SURE THAT THERE ARE NO INDIRECT TRANSITIVES.
    ----------------------------------------------------------------------------------------------

    -- At the end of this, we would have the following:

    -- Only rows with score >= threshold.
    -- The pair with f_osr < t_osr, if both the pairs have the same score.
    -- The pair with the higher score, if in case, the pairs of different scores.

     /* -- WE WILL BE REPLACING THIS BY AN INSERT TO A TEMP TABLE
        --   SINCE DELETE IS PERFORMANCE PROHIBITIVE.
        delete from hz_int_dup_results a
        where
          -- delete anything less than the threshold
          (a.score < p_threshold and a.batch_id = p_batch_id);

        delete from hz_int_dup_results a
        where
        a.batch_id = p_batch_id
        and
          -- if scores are same, delete the one with highest source
          -- or if scores are different, delete the one with lower score
          (exists
            (Select 1 from hz_int_dup_results b
             where
               (
                -- APPLY THE ABOVE PRINCIPLE TO REVERSED PAIRS
                 a.f_osr=b.t_osr and b.f_osr=a.t_osr and b.batch_id = p_batch_id and
                 ( (a.score = b.score and a.f_osr > b.f_osr) or (a.score < b.score) )
                )

                or
                -- APPLY THE ABOVE PRINCIPLE TO INDIRECT TRANSITIVES
                ( a.t_osr=b.t_osr and b.batch_id = p_batch_id and
                ((a.score = b.score and a.f_osr > b.f_osr) or (a.score < b.score))
                )
             )
            ) ;

         */



-- for a to be inserted into the temporary table the folowing should be true:
--  1. a should exceed the threshold
--  2. There should not be any b in the same batch
--   which
--   EITHER
--   is reversed and has the (same score and whose f_osr is small) or (whose score exceeds a)
--   OR
--   is transitive and has the (same score and whose f_osr is small) or (whose score exceeds a)


select count(1) into p_count
from hz_int_dup_results
where batch_id = p_batch_id;

FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of parties in HZ_INT_DUP_RESULTS before sanitization '|| p_count );
FND_FILE.put_line(FND_FILE.log,'Parties ::: Begin time of insert '||to_char(sysdate,'hh24:mi:ss'));


-- Bug fix for 3639346 :::: Need to take scores that are >= threshold
insert into hz_int_dup_results_gt (batch_id, f_osr, f_os, t_osr, t_os, ord_f_osr, ord_t_osr, score)
select a.batch_id, a.f_osr, a.f_os, a.t_osr, a.t_os, a.ord_f_osr, a.ord_t_osr, a.score
from hz_int_dup_results a
where
(a.score >= p_threshold and a.batch_id = p_batch_id)
and
not exists
   (select 1 from hz_int_dup_results b
         where
	 b.batch_id = p_batch_id
         and
         (
		 (
			  a.f_osr=b.t_osr and b.f_osr=a.t_osr and
			  ( (a.score = b.score and b.f_osr < a.f_osr) or (a.score < b.score) )
		 )

	  or

		(
			  a.t_osr=b.t_osr and
			  ((a.score = b.score and b.f_osr < a.f_osr ) or (a.score < b.score))
		)
          )
    );

   FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
   FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of parties inserted to HZ_INT_DUP_RESULTS_GT '||SQL%ROWCOUNT);
   FND_FILE.put_line(FND_FILE.log,'Parties ::: End time of insert '||to_char(sysdate,'hh24:mi:ss'));


         EXCEPTION
         WHEN OTHERS THEN
                   FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROC' ,'SANITIZE_INT_DUP_PARTY_OSRS');
                   FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END;


PROCEDURE  final_process_int_dup_id(p_batch_id number)
IS
l_count number;
BEGIN

         -- we need to populate the batch summary table with all the counts
         -- update party count
         update hz_imp_batch_summary h
         set dup_parties_in_batch =
         (select count(1) from
            (select distinct winner_record_osr
            from hz_imp_int_dedup_results
            where batch_id =  p_batch_id
            and entity = 'PARTY'
            union
            select distinct dup_record_osr
            from hz_imp_int_dedup_results
            where batch_id =  p_batch_id
            and entity = 'PARTY'
            )
          )
          where
          h.batch_id = p_batch_id ;

         -- update party set count
         update hz_imp_batch_summary h
         set party_dup_sets_in_batch =
         (select count(1) from
            (select distinct winner_record_osr
            from hz_imp_int_dedup_results
            where batch_id =  p_batch_id
            and entity = 'PARTY'
            )
          )
          where
          h.batch_id = p_batch_id ;

          -- update party site count
         update hz_imp_batch_summary h
         set dup_addresses_in_batch =
         (select count(1) from
            (select distinct winner_record_osr
            from hz_imp_int_dedup_results
            where batch_id =  p_batch_id
            and entity = 'PARTY_SITES'
            union
            select distinct dup_record_osr
            from hz_imp_int_dedup_results
            where batch_id =  p_batch_id
            and entity = 'PARTY_SITES'
            )
          )
          where
          h.batch_id = p_batch_id ;

         -- update party site set count
         update hz_imp_batch_summary h
         set address_dup_sets_in_batch =
         (select count(1) from
            (select distinct winner_record_osr
            from hz_imp_int_dedup_results
            where batch_id =  p_batch_id
            and entity = 'PARTY_SITES'
            )
          )
          where
          h.batch_id = p_batch_id ;

          -- update contacts count
         update hz_imp_batch_summary h
         set dup_contacts_in_batch =
         (select count(1) from
            (select distinct winner_record_osr
            from hz_imp_int_dedup_results
            where batch_id =  p_batch_id
            and entity = 'CONTACTS'
            union
            select distinct dup_record_osr
            from hz_imp_int_dedup_results
            where batch_id =  p_batch_id
            and entity = 'CONTACTS'
            )
          )
          where
          h.batch_id = p_batch_id ;

         -- update contacts set count
         update hz_imp_batch_summary h
         set contact_dup_sets_in_batch =
         (select count(1) from
            (select distinct winner_record_osr
            from hz_imp_int_dedup_results
            where batch_id =  p_batch_id
            and entity = 'CONTACTS'
            )
          )
          where
          h.batch_id = p_batch_id ;


          -- update contact point count
         update hz_imp_batch_summary h
         set dup_contactpoints_in_batch =
         (select count(1) from
            (select distinct winner_record_osr
            from hz_imp_int_dedup_results
            where batch_id =  p_batch_id
            and entity = 'CONTACT_POINTS'
            union
            select distinct dup_record_osr
            from hz_imp_int_dedup_results
            where batch_id =  p_batch_id
            and entity = 'CONTACT_POINTS'
            )
          )
          where
          h.batch_id = p_batch_id ;

         -- update contact point set count
         update hz_imp_batch_summary h
         set contactpoint_dup_sets_in_batch =
         (select count(1) from
            (select distinct winner_record_osr
            from hz_imp_int_dedup_results
            where batch_id =  p_batch_id
            and entity = 'CONTACT_POINTS'
            )
          )
          where
          h.batch_id = p_batch_id ;

         EXCEPTION
         WHEN OTHERS THEN
                   FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROC' ,'FINAL_PROCESS_INT_TCA_DUP_ID');
                   FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END;
PROCEDURE  sanitize_int_dup_detail_osrs(p_batch_id number)
IS
p_count number;
BEGIN
        select count(1) into p_count
        from hz_imp_int_dedup_results
        where batch_id = p_batch_id
        and entity <> 'PARTY' ;

        FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
        FND_FILE.put_line(FND_FILE.log,'Details ::: Number of details in HZ_IMP_INT_DEDUP_RESULTS before sanitization '|| p_count );
        FND_FILE.put_line(FND_FILE.log,'Details ::: Begin time of delete '||to_char(sysdate,'hh24:mi:ss'));


         delete from hz_imp_int_dedup_results a
         where
         (exists
            (Select 1 from hz_imp_int_dedup_results b
             where
               (
                 -- DELETE DIRECT TRANSITIVE DETAIL OSRS FOR THIS BATCH
                 -- WE BASICALLY MAKE SURE THAT A DETAIL RECORD OSR
                 -- CANNOT BE A WINNER RECORD OSR, FOR A GIVEN DETAIL PARTY OSR

                 a.batch_id = p_batch_id and
                 a.entity <> 'PARTY' and
                 a.batch_id = b.batch_id and
                 a.entity = b.entity AND      -- bug 5393826
                 a.winner_record_osr=b.dup_record_osr -- bug 5393826
                )
             )
          );

          FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
          FND_FILE.put_line(FND_FILE.log,'Details ::: Number of details deleted in HZ_IMP_INT_DEDUP_RESULTS '||SQL%ROWCOUNT);
          FND_FILE.put_line(FND_FILE.log,'Details ::: End time of delete '||to_char(sysdate,'hh24:mi:ss'));

         -- bug 5393826
          FND_FILE.put_line(FND_FILE.log,'Details ::: Start time of insert of Winner Detail OSRS '||to_char(sysdate,'hh24:mi:ss'));
         insert into hz_imp_int_dedup_results
        (batch_id,
         winner_record_osr,
         winner_record_os,
         dup_record_osr,
         dup_record_os,
         detail_party_osr,
         entity,
         score
         )
        select   distinct p_batch_id,
         winner_record_osr,
         winner_record_os,
         winner_record_osr,
         winner_record_os,
         detail_party_osr,
         entity,
         0
       from hz_imp_int_dedup_results a
       where a.entity <> 'PARTY'
       and a.batch_id = p_batch_id ;

        FND_FILE.put_line(FND_FILE.log,'Details ::: End time of insert of Winner Detail OSRs '||to_char(sysdate,'hh24:mi:ss'));
        FND_FILE.put_line(FND_FILE.log,'Details ::: Number of Winner Detail OSRs inserted '||SQL%ROWCOUNT);

         -- bug 5393826


         -- Bug Fix 3588873 :: Need to report the import interface table dates for all the duplicates


         FND_FILE.put_line(FND_FILE.log,'Details ::: End time of update for getting import table dates '||to_char(sysdate,'hh24:mi:ss'));

         -- We take of the "PARTY SITES" entity here.
         update hz_imp_int_dedup_results a
         set (a.dup_creation_date, a.dup_last_update_date)
              = (select b.creation_date, b.last_update_date
                 from hz_imp_addresses_int b
                 where b.batch_id = p_batch_id
                 and b.site_orig_system_reference = a.dup_record_osr
                 and b.site_orig_system = a.dup_record_os
                  )
          where a.entity = 'PARTY_SITES' and a.batch_id = p_batch_id ;

         -- We take of the "CONTACTS" entity here.
         update hz_imp_int_dedup_results a
         set (a.dup_creation_date, a.dup_last_update_date)
              = (select b.creation_date, b.last_update_date
                 from hz_imp_contacts_int b
                 where b.batch_id = p_batch_id
                 and b.contact_orig_system_reference = a.dup_record_osr
                 and b.contact_orig_system = a.dup_record_os
                  )
          where a.entity = 'CONTACTS' and a.batch_id = p_batch_id ;

          -- We take of the "CONTACT POINTS" entity here.
          update hz_imp_int_dedup_results a
          set (a.dup_creation_date, a.dup_last_update_date)
              = (select b.creation_date, b.last_update_date
                 from hz_imp_contactpts_int b
                 where b.batch_id = p_batch_id
                 and b.cp_orig_system_reference = a.dup_record_osr
                 and b.cp_orig_system = a.dup_record_os
                  )
          where a.entity = 'CONTACT_POINTS' and a.batch_id = p_batch_id ;

        FND_FILE.put_line(FND_FILE.log,'Details ::: Number of duplicate details updated in HZ_IMP_INT_DEDUP_RESULTS '||SQL%ROWCOUNT);
        FND_FILE.put_line(FND_FILE.log,'Details ::: End time of update for getting import table dates '||to_char(sysdate,'hh24:mi:ss'));

         EXCEPTION
         WHEN OTHERS THEN
                   FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROC' ,'SANITIZE_INT_DUP_DETAIL_OSRS');
                   FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END;


PROCEDURE  report_tca_dup_parties (
                p_batch_id              IN NUMBER,
                p_threshold             IN NUMBER,
                p_auto_merge_threshold  IN NUMBER
)
IS
p_count number ;
BEGIN

-- FIRST, REPORT WINNER PARTIES TO DUP SETS
-- THESE ARE ALL PRECISELY THE ORD_FIDs IN HZ_DUP_RESULTS WHICH ARE NOT ORD_TIDs
-- OF ANY ROW AND OCCUR AT ODD LEVELS IN THE CONNECT BY.

----------------------------------------------------
--- EXAMPLE :
-- 1 2  LEVEL 1
-- 2 3  LEVEL 2
-- 3 4  LEVEL 3
-- 1 7  LEVEL 1
-- WOULD RESULT IN 1 AND 2 BEING CHOSEN AS WINNER PARTIES
-- AFTER THE CONNECT BY. SO THE CONNECT BY NOT ONLY CHOOSES
-- THE WINNER, BUT ALSO MAKES SURE THAT ODD LEVELS ARE TAKEN
-- INTO ACCOUNT.
-----------------------------------------------------

        select count(1) into p_count
        from hz_dup_results ;

        FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
        FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of parties in HZ_DUP_RESULTS before reporting '|| p_count );
        FND_FILE.put_line(FND_FILE.log,'Parties ::: Begin time of insert '||to_char(sysdate,'hh24:mi:ss'));


insert into hz_dup_sets ( winner_party_id, dup_set_id, dup_batch_id,
                          status, merge_type, created_by, creation_date, last_update_login,
                          last_update_date, last_updated_by)
select win_party_id, HZ_MERGE_BATCH_S.nextval, p_batch_id,
       'SYSBATCH', 'PARTY_MERGE', hz_utility_pub.created_by, hz_utility_pub.creation_date,
       hz_utility_pub.last_update_login, hz_utility_pub.last_update_date,
       hz_utility_pub.user_id
from
(
select distinct d.ord_fid as win_party_id, level as levelu
from hz_dup_results d
start with d.ord_fid not in
   (
        select c.ord_tid
        from hz_dup_results c
   )
connect by prior ord_tid = ord_fid
)
where mod(levelu, 2) = 1 ;

   FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
   FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of parties inserted to Dup Sets '||SQL%ROWCOUNT);
   FND_FILE.put_line(FND_FILE.log,'Parties ::: End time of insert '||to_char(sysdate,'hh24:mi:ss'));


-- REPORT WINNER AND ALL ITS DUPLICATES ( ONE OR MORE) TO HZ_DUP_SET_PARTIES

    FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
    FND_FILE.put_line(FND_FILE.log,'Parties ::: Begin time of insert '||to_char(sysdate,'hh24:mi:ss'));


-- this is the part for the winner
insert into hz_dup_set_parties (dup_party_id, dup_set_id,merge_seq_id,
             merge_batch_id,score,merge_flag, created_by,creation_date,last_update_login,
             last_update_date,last_updated_by,dup_set_batch_id) --Bug No: 4244529
select  a.winner_party_id, a.dup_set_id, 0, 0, 100 ,'Y',
                    hz_utility_pub.created_by,hz_utility_pub.creation_date,
                    hz_utility_pub.last_update_login,hz_utility_pub.last_update_date,
                    hz_utility_pub.user_id,a.dup_batch_id --Bug No: 4244529
from hz_dup_sets a
where a.dup_batch_id = p_batch_id
union all
-- this is the part for all the duplicates of the winner
-- basically compare the winner from dup set to any row which has the winner has its ord_fid
-- and pick up its ord_tid.
select  b.ord_tid, a.dup_set_id, 0, 0, b.score ,decode( sign(b.score - p_auto_merge_threshold),-1,'N','Y'),
                    hz_utility_pub.created_by,hz_utility_pub.creation_date,
                    hz_utility_pub.last_update_login,hz_utility_pub.last_update_date,
                    hz_utility_pub.user_id,a.dup_batch_id
from hz_dup_sets a, hz_dup_results b
where a.dup_batch_id = p_batch_id
and a.winner_party_id = b.ord_fid ;

   FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of parties inserted to Dup Set Parties'||SQL%ROWCOUNT);
   FND_FILE.put_line(FND_FILE.log,'Parties ::: End time of insert '||to_char(sysdate,'hh24:mi:ss'));





---------- exception block ---------------
        EXCEPTION
        WHEN OTHERS THEN
                 FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
                 FND_MESSAGE.SET_TOKEN('PROC','REPORT_TCA_DUP_PARTIES');
                 FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM );
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END;

FUNCTION check_bulk_feature return BOOLEAN IS

  TYPE PartyCurTyp IS REF CURSOR;
  pt_cur PartyCurTyp;

  TYPE Nlist is table of number;
  pidlist NList;

begin
  open pt_cur for 'select party_id from hz_parties where rownum<3';
  fetch pt_cur bulk collect into pidlist;
  close pt_cur;
  return true;
exception
  when others then
    if pt_cur%isopen THEN
      close pt_cur;
    end if;
    return false;
end;


PROCEDURE tca_dup_id_worker(
                 p_dup_batch_id            IN NUMBER,
                 p_match_rule_id           IN NUMBER,
                 p_worker_number           IN NUMBER,
                 p_number_of_workers       IN NUMBER,
                 p_subset_sql              IN VARCHAR2
                 )
IS
l_owner VARCHAR2(30);
l_pkg_name varchar2(2000);
anon_str varchar2(255);
x_inserted_duplicates number := 0;
x_rows_in_chunk number := 0;
pid_list NumberList;
cnt number :=1;
chunk_limit number :=50;
l_last_fetch BOOLEAN := FALSE;
x_trap_explosion varchar2(1) := 'Y';

TYPE PartyCurTyp IS REF CURSOR;
pt_cur PartyCurTyp;

start_idx NUMBER;
end_idx NUMBER;
fetch_from_party_cursor BOOLEAN;
bulk_feature_exists boolean;


BEGIN
        -- check if bulk fetch feature exists for this version of the database
        bulk_feature_exists := check_bulk_feature;

        -- get the match rule package
        l_pkg_name := 'HZ_IMP_MATCH_RULE_'||p_match_rule_id;



         -- we first need to make sure that the subset of parties that we get for
         -- this worker, satisfy the subset sql. The basic idea is that, we need
         -- to make sure that the source parties that we begin with are in the subset sql,
         -- before finding their duplicates

         --Adding the condition of Status = A, to the 2 cursors below to fix bug 4669400.
         --This will make sure that the Merged and Inactive Parties (with status as 'M' and 'I')
         --will not be considered for duplicate idenfication.

         FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------');

         FND_FILE.put_line(FND_FILE.log,'Start Time before insert to hz_dqm_stage_gt ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
         IF p_subset_sql IS NULL
         THEN
         /*   OPEN pt_cur FOR
             'SELECT parties.PARTY_ID FROM HZ_PARTIES parties WHERE parties.PARTY_TYPE <> ''PARTY_RELATIONSHIP'' AND NVL (parties.STATUS,''A'') = ''A'' AND mod(parties.PARTY_ID, :num_workers) = :worker_number' */
             execute immediate
                'insert /*+ APPEND */  into HZ_MATCHED_PARTIES_GT(party_id)
                SELECT  /*+ INDEX(parties HZ_PARTIES_U1) */ parties.PARTY_ID FROM HZ_PARTIES parties WHERE parties.PARTY_TYPE <> ''PARTY_RELATIONSHIP''
                AND NVL(parties.STATUS,''A'') = ''A'' AND mod(parties.PARTY_ID, :num_workers) = :worker_number '
                       USING p_number_of_workers, p_worker_number;
               FND_FILE.put_line(FND_FILE.log,'Number of parties inserted into HZ_MATCHED_PARTIES_GT by worker '||p_worker_number||' is '||SQL%ROWCOUNT );       -- BUG 5351721
         ELSE
        /*    OPEN pt_cur FOR
            'SELECT PARTY_ID FROM HZ_PARTIES parties WHERE parties.PARTY_TYPE <> ''PARTY_RELATIONSHIP'' AND NVL (parties.STATUS,''A'') = ''A'' AND mod(parties.PARTY_ID, :num_workers) = :worker_number AND '||
                p_subset_sql  */
               execute immediate
                'insert /*+ APPEND */  into HZ_MATCHED_PARTIES_GT(party_id)
                SELECT /*+ INDEX(parties HZ_PARTIES_U1) */ PARTY_ID FROM HZ_PARTIES parties WHERE parties.PARTY_TYPE <> ''PARTY_RELATIONSHIP'' AND NVL(parties.STATUS,''A'') = ''A''
                AND mod(parties.PARTY_ID, :num_workers) = :worker_number AND '||
                p_subset_sql   USING p_number_of_workers, p_worker_number;
                FND_FILE.put_line(FND_FILE.log,'Number of parties inserted into HZ_MATCHED_PARTIES_GT by worker '||p_worker_number||' is '||SQL%ROWCOUNT );      -- BUG 5351721
         END IF;
         FND_FILE.put_line(FND_FILE.log,'End Time after insert to HZ_MATCHED_PARTIES_GT ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
         COMMIT;


         OPEN pt_cur FOR 'select party_id from HZ_MATCHED_PARTIES_GT';       -- BUG 5351721


         -- we always fetch from the pid list, unless the chunk explodes
         fetch_from_party_cursor :=true;

         LOOP
             FND_FILE.put_line(FND_FILE.log,'Start Time before processing chunk ' || cnt || ' ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));       -- BUG 5351721
             IF NOT fetch_from_party_cursor THEN
                         --dbms_output.put_line('chunk_num '||cnt);
                         IF start_idx<pid_list.COUNT THEN
                               IF (start_idx+chunk_limit-1)<(pid_list.COUNT) THEN
                                 end_idx := start_idx+chunk_limit-1;
                               ELSE
                                 end_idx := pid_list.COUNT;
                               END IF;
                               -- dbms_output.put_line('start '||start_idx);
                               -- dbms_output.put_line('end '||end_idx);
                               -- dbms_output.put_line('limit '||chunk_limit);
                               /* insert into hz_dup_results(fid, tid, ord_fid, ord_tid, score,chunk_num,chunk_stime)
                               values (-1,-1,-1,-1,chunk_limit,cnt,sysdate);
                               */

                               -- truncate chunk table before inserting into it
                               l_owner := HZ_IMP_DQM_STAGE.get_owner_name('HZ_DUP_WORKER_CHUNK_GT', 'TABLE');
                               execute immediate ' truncate table ' || l_owner || '.HZ_DUP_WORKER_CHUNK_GT';

                               FORALL I in start_idx..end_idx
                                 INSERT INTO hz_dup_worker_chunk_gt values (pid_list(I));

                               x_rows_in_chunk:=SQL%ROWCOUNT;

                               DELETE FROM hz_dup_worker_chunk_gt WHERE
                                EXISTS (Select 1 from HZ_DUP_RESULTS t
                                        WHERE t.tid = party_id);
                               x_rows_in_chunk:=x_rows_in_chunk-SQL%ROWCOUNT;
                               start_idx:=start_idx+chunk_limit;
                        ELSE
                           fetch_from_party_cursor:=TRUE;
                END IF;

               END IF;

               IF fetch_from_party_cursor THEN

                       -- fetch a chunk of party ids and note that the chunk limit
                       -- changes dynamically
                       -- not that the chunk limit would always be atleast 50.

                        IF bulk_feature_exists THEN
                            FETCH pt_cur BULK COLLECT INTO pid_list limit chunk_limit;
                        ELSE
                            pid_list.DELETE;
                            FOR I in 1..chunk_limit
                            LOOP
                                FETCH pt_cur  INTO pid_list(I);
                                EXIT WHEN pt_cur%NOTFOUND;
                            END LOOP;
                        END IF;

                         -- mark it if the cursor is empty
                         IF pt_cur%NOTFOUND THEN
                          l_last_fetch:=TRUE;
                         END IF;


                         /*
                         insert into hz_dup_results(fid, tid, ord_fid, ord_tid, score,chunk_num,chunk_stime)
                         values (-1,-1,-1,-1,chunk_limit,cnt,sysdate);
                         */
                         -- truncate chunk table before inserting into it
                         l_owner := HZ_IMP_DQM_STAGE.get_owner_name('HZ_DUP_WORKER_CHUNK_GT', 'TABLE');
                         execute immediate ' truncate table ' || l_owner || '.HZ_DUP_WORKER_CHUNK_GT';

                         -- insert all the parties in the chunk to the temp table
                         FORALL I in 1..pid_list.COUNT
                            INSERT INTO hz_dup_worker_chunk_gt values (pid_list(I));

                         x_rows_in_chunk:=SQL%ROWCOUNT;

                         -- remove any party ids from temp table if in case
                         -- dups have been found already for them
                         -- so that collision does not happen
                         -- ( for example if 1 finds 2 as a duplicate
                         -- we would like to avoid doing anything with 2, if 2 indeed happens
                         -- to be allocated to this worker )
                         DELETE FROM hz_dup_worker_chunk_gt WHERE
                          EXISTS (Select 1 from HZ_DUP_RESULTS t
                                  WHERE t.tid = party_id);

                         x_rows_in_chunk:=x_rows_in_chunk-SQL%ROWCOUNT;
                         FND_FILE.put_line(FND_FILE.log,'Number of rows in chunk table ' || x_rows_in_chunk);
               END IF;

           -- set the trap for the explosion depending on the number of rows in the chunk
           IF x_rows_in_chunk < 50
           THEN
                x_trap_explosion := 'N' ;
           END IF;

           -- EXECUTE IMMEDIATE sql_stmt USING my_sal, my_empno, OUT my_ename, OUT my_job;
           -- build the string to execute the match rule package
           anon_str := 'begin ' ||l_pkg_name ||'.tca_join_entities(:x_trap_explosion,:x_rows_in_chunk,:x_inserted_duplicates); end;' ;

           -- call the corresponding function in this match rule package, to do the
           -- joins on entities based on the match rule, for this chunk
           EXECUTE IMMEDIATE anon_str USING IN x_trap_explosion, IN x_rows_in_chunk, OUT x_inserted_duplicates  ;

           commit;

           FND_FILE.put_line(FND_FILE.log,'End Time after processing chunk ' || cnt || ' ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));        -- BUG 5351721
           FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------');
           FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------');
           cnt := cnt+1;

           -- if the chunk explodes, process in chunks of 25
           IF x_inserted_duplicates = -1
           THEN
             -- dbms_output.put_line('in chunk explosion ');
             IF fetch_from_party_cursor THEN
               start_idx :=1;
               fetch_from_party_cursor :=FALSE;
             ELSE
               start_idx:=start_idx-chunk_limit;
             END IF;
             chunk_limit:=25;

           -- change chunk limit as you go
           -- if inserted rows is less than 50, increase the chunk size
           -- else halve the chunk size, making sure that the rounding of
           -- the arithmetic yields an integer, for the size.

           ELSIF (x_inserted_duplicates < 50 )
           THEN
                chunk_limit:=chunk_limit*2;
           ELSE
                chunk_limit:=greatest(round(chunk_limit/2),25);
           END IF;


           IF l_last_fetch AND fetch_from_party_cursor
           THEN
                EXIT;
           END IF;


         END LOOP;
         CLOSE pt_cur;

      EXCEPTION
           WHEN OTHERS THEN
                   FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROC' ,'TCA_DUP_ID_WORKER');
                   FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END ;

PROCEDURE tca_sanitize_report(
                 p_dup_batch_id            IN NUMBER,
                 p_match_rule_id           IN NUMBER,
                 p_subset_sql              IN VARCHAR2,
                 p_within_subset           IN VARCHAR2
                 )
IS
x_threshold number;
x_auto_merge_threshold number;
ret_value number;
l_pkg_name varchar2(2000);
BEGIN

       FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
       FND_FILE.put_line(FND_FILE.log,'Entering tca_sanitize_report ');



        -- get the threshold and the auto merge threshold
        select match_score, auto_merge_score into x_threshold, x_auto_merge_threshold
        from hz_match_rules_vl
        where match_rule_id = p_match_rule_id;

        -- sanitize data in temp tables that get populated by the match rule
        sanitize_tca_dup_parties ( x_threshold, x_auto_merge_threshold, p_subset_sql,
                                   p_within_subset);

        -- report duplicate parties to hz_dup_sets aand hz_dup_set_parties
        report_tca_dup_parties (
                p_dup_batch_id, x_threshold, x_auto_merge_threshold );

        -- exception block
         EXCEPTION
           WHEN OTHERS THEN
                   FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROC' ,'TCA_SANITIZE_REPORT');
                   FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END ;




-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-- INTERFACE TCA DUP IDENTIFICATION
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

/**
 * PROCEDURE update_hz_imp_dup_parties
 *
 * DESCRIPTION
 *
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   04-09-2003  Colathur Vijayan       o Created.
 *
 */

--------------------------------------------------------------------------------------
-- update_hz_imp_dup_parties ::: This is a generic procedure, that would do a bulk update
--                           of hz_dup_results, using a passed in open cursor
--------------------------------------------------------------------------------------


PROCEDURE update_hz_imp_dup_parties (
    p_batch_id IN number,
    p_cur    IN EntityCur )
is
    l_limit NUMBER := 200;
    l_last_fetch BOOLEAN := FALSE;
    H_PARTY_ID NumberList;
    H_DUP_PARTY_ID NumberList ;
    H_SCORE NumberList ;

BEGIN

    -- LOOP THROUGH THE PASSED IN OPEN CURSOR
    LOOP
          FETCH p_cur BULK COLLECT INTO
                H_PARTY_ID
              , H_DUP_PARTY_ID
               ,H_SCORE
          LIMIT l_limit;

          IF p_cur%NOTFOUND THEN
            l_last_fetch:=TRUE;
          END IF;

          IF H_PARTY_ID.COUNT = 0 and l_last_fetch THEN
            EXIT;
          END IF;

          BEGIN

              FORALL I in H_PARTY_ID.FIRST..H_DUP_PARTY_ID.LAST
                UPDATE HZ_IMP_DUP_PARTIES A
                SET A.SCORE = A.SCORE + H_SCORE(I)
                WHERE
                   ( A.PARTY_ID = H_PARTY_ID(I) and
                     A.DUP_PARTY_ID = H_DUP_PARTY_ID(I) and
                     A.BATCH_ID = p_batch_id
                     );
          END;

          IF l_last_fetch THEN
          EXIT;

          END IF;
    END LOOP;
    ---------- exception block ---------------
    EXCEPTION
    WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
         FND_MESSAGE.SET_TOKEN('PROC','UPDATE_HZ_IMP_DUP_PARTIES');
         FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;


PROCEDURE  report_int_tca_dup_parties (
                p_batch_id              IN NUMBER,
                p_match_rule_id         IN NUMBER,
                p_request_id            IN NUMBER,
                l_dup_batch_id          OUT NOCOPY NUMBER,
                l_party_count           OUT NOCOPY NUMBER
)
IS
p_batch_name varchar2(255);
p_count number ;
BEGIN

   -- GET INTERFACE BATCH NAME
   select batch_name into p_batch_name
   from hz_imp_batch_summary
   where batch_id = p_batch_id;

   -- CALL THE HZ_DUP_BATCH TABLE HANDLER, INSERT A ROW
   -- FOR THIS INTERFACE BATCH AND ALSO GET THE BATCH ID
   -- FOR REPORTING THESE DUPLICATES TO HZ_DUP_SETS
   -- AND HZ_DUP_PARTIES

   HZ_DUP_BATCH_PKG.Insert_Row(
      px_dup_batch_id     => l_dup_batch_id
     ,p_dup_batch_name    => p_batch_name
     ,p_match_rule_id     => p_match_rule_id
     ,p_application_id    => '222'
     ,p_request_type      => 'IMPORT'
     ,p_created_by        => HZ_UTILITY_V2PUB.CREATED_BY
     ,p_creation_date     => HZ_UTILITY_V2PUB.CREATION_DATE
     ,p_last_update_login => HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN
     ,p_last_update_date  => HZ_UTILITY_V2PUB.LAST_UPDATE_DATE
     ,p_last_updated_by   => HZ_UTILITY_V2PUB.LAST_UPDATED_BY
   );

   -- THIS IS ADDED FOR AUTOMERGE
   -- WE WANT TO IDENTIFY BATCHES THAT ARE AUTO MERGE ENABLED

    update hz_dup_batch
    set automerge_flag = (select automerge_flag
                          from hz_match_rules_vl
                          where match_rule_id = p_match_rule_id)
    where dup_batch_id = l_dup_batch_id ;

   -- NOTE: WINNERS ARE TCA PARTIES
   --       DUPS ARE INTERFACE PARTIES



    -- INSERT INTO HZ_DUP_SETS, ALL THE DISTINCT DUP_PARTY_IDs WHICH OCCUR IN HZ_IMP_DUP_PARTIES
    -- AS WINNERS, FOR THE GIVEN BATCH PROVIDED THE FOLLOWING CONDITION IS MET.
    -- 1. THE WINNER HAS ATLEAST A PARTY ID ASSOCIATED WITH IT, WHICH HAS
    -- ITS AUTO MERGE FLAG <> 'R' AND IS LOADED

    select count(1) into p_count
    from hz_imp_dup_parties
    where batch_id = p_batch_id;

   FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
   FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of parties in HZ_IMP_DUP_PARTIES before reporting '|| p_count );
   FND_FILE.put_line(FND_FILE.log,'Parties ::: Begin time of insert '||to_char(sysdate,'hh24:mi:ss'));

    insert into hz_dup_sets ( winner_party_id, dup_set_id, dup_batch_id,
                          status, merge_type, created_by, creation_date, last_update_login,
                          last_update_date, last_updated_by)
    select win_party_id, HZ_MERGE_BATCH_S.nextval, l_dup_batch_id,
       'SYSBATCH', 'PARTY_MERGE', hz_utility_pub.created_by, hz_utility_pub.creation_date,
       hz_utility_pub.last_update_login, hz_utility_pub.last_update_date,
       hz_utility_pub.user_id
    from
        (select distinct h.dup_party_id as win_party_id
         from hz_imp_dup_parties h
         where h.batch_id = p_batch_id
         and exists (select a.party_id
                     from hz_imp_dup_parties a, hz_parties b
                     where a.batch_id = p_batch_id
                     and a.dup_party_id = h.dup_party_id
                     and a.auto_merge_flag <> 'R'
                     and a.party_id = b.party_id
                     and b.request_id = p_request_id
                       )
         ) ;

   -- This is the number of winner parties ( and equivalently the number of dup sets )
   p_count := SQL%ROWCOUNT ;

   FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
   FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of parties inserted to Dup Sets '|| p_count );
   FND_FILE.put_line(FND_FILE.log,'Parties ::: End time of insert '||to_char(sysdate,'hh24:mi:ss'));

    -- INSERT WINNER AND ALL ITS DUPLICATES TO HZ_DUP_SET_PARTIES
    FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
    FND_FILE.put_line(FND_FILE.log,'Parties ::: Begin time of insert '||to_char(sysdate,'hh24:mi:ss'));
    -- this is the part for the winner
    insert into hz_dup_set_parties (dup_party_id, dup_set_id,merge_seq_id,
                 merge_batch_id,score,merge_flag, created_by,creation_date,last_update_login,
                 last_update_date,last_updated_by,dup_set_batch_id) --Bug No: 4244529
    select  a.winner_party_id, a.dup_set_id, 0, 0, 100 ,'Y',
                        hz_utility_pub.created_by,hz_utility_pub.creation_date,
                        hz_utility_pub.last_update_login,hz_utility_pub.last_update_date,
                        hz_utility_pub.user_id,a.dup_batch_id --Bug No: 4244529
    from hz_dup_sets a
    where a.dup_batch_id = l_dup_batch_id
    union all
    -- this is the part for all the duplicates of the winner
    -- basically compare the winner from dup set to any row which has the winner
    -- as its dup_party_id and pick up the corresponding interface party id,
    -- provided the following conditions are met:
    -- 1. The interface party id has been loaded
    -- 2. The interface party id does not have an automerge flag of 'R'
    select  b.party_id, a.dup_set_id, 0, p_batch_id, b.score , b.auto_merge_flag,
                        hz_utility_pub.created_by,hz_utility_pub.creation_date,
                        hz_utility_pub.last_update_login,hz_utility_pub.last_update_date,
                        hz_utility_pub.user_id,a.dup_batch_id --Bug No: 4244529
    from hz_dup_sets a, hz_imp_dup_parties b, hz_parties c
    where a.dup_batch_id = l_dup_batch_id
    and a.winner_party_id = b.dup_party_id
    and b.party_id = c.party_id
    and c.request_id = p_request_id
    and b.auto_merge_flag <> 'R' ;

   -- The total number of parties inserted into hz_dup_set_parties
   l_party_count := SQL%ROWCOUNT ;

   FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of parties inserted to Dup Set Parties '|| l_party_count);
   FND_FILE.put_line(FND_FILE.log,'Parties ::: End time of insert '||to_char(sysdate,'hh24:mi:ss'));

   -- Number of parties in interface for which a merge has been requested
   --  =  (Total number of parties inserted into dup set parties - Number of winners)
   l_party_count := l_party_count - p_count ;

   -- update HZ_IMP_BATCH_SUMMARY with this count
   update hz_imp_batch_summary h
   set party_merge_requests = l_party_count
   where h.batch_id = p_batch_id ;

   FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of merge request parties inserted into batch summary table is '
                                                   || l_party_count);


    EXCEPTION
           WHEN OTHERS THEN
                   FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROC' ,'REPORT_INT_TCA_DUP_PARTIES');
                   FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END ;

PROCEDURE  report_int_tca_dup_details (
                p_batch_id              IN NUMBER,
                p_match_rule_id         IN NUMBER,
                p_request_id            IN NUMBER,
                l_dup_batch_id          IN NUMBER,
                l_party_count           IN OUT NOCOPY NUMBER
)
IS
p_count number ;
ps_count number ;
c_count number ;
cp_count number ;
BEGIN

    -- INSERT INTO HZ_DUP_SETS, ALL THE DISTINCT PARTY_IDs WHICH OCCUR IN HZ_IMP_DUP_DETAILS
    -- FOR THE GIVEN BATCH, PROVIDED THE FOLLOWING CONDITION IS MET:
    -- 1. ALL THE WINNER PARTIES SHOULD HAVE ATLEAST ONE DETAIL THAT HAS BEEN
    --    LOADED TO TCA.

    select count(1) into p_count
    from hz_imp_dup_details
    where batch_id = p_batch_id;

   FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
   FND_FILE.put_line(FND_FILE.log,'Details ::: Number of parties in HZ_IMP_DUP_DETAILS before reporting'|| p_count );
   FND_FILE.put_line(FND_FILE.log,'Details ::: Begin time of insert '||to_char(sysdate,'hh24:mi:ss'));

    insert into hz_dup_sets ( winner_party_id, dup_set_id, dup_batch_id,
                          status, merge_type, created_by, creation_date, last_update_login,
                          last_update_date, last_updated_by)
    select win_party_id, HZ_MERGE_BATCH_S.nextval, l_dup_batch_id,
       'SYSBATCH', 'SAME_PARTY_MERGE', hz_utility_pub.created_by, hz_utility_pub.creation_date,
       hz_utility_pub.last_update_login, hz_utility_pub.last_update_date,
       hz_utility_pub.user_id
    from
        (select distinct h.party_id as win_party_id
         from hz_imp_dup_details h
         where h.batch_id = p_batch_id
         and
         (
            exists (select a.dup_record_id
                     from hz_imp_dup_details a, hz_party_sites b
                     where a.party_id = h.party_id
                     and a.batch_id = p_batch_id
                     and a.record_id = b.party_site_id
                     and b.request_id = p_request_id
                       )
             or
             exists (select a.dup_record_id
             from hz_imp_dup_details a, hz_contact_points b
             where a.party_id = h.party_id
             and a.batch_id = p_batch_id
             and a.record_id = b.contact_point_id
             and b.request_id = p_request_id
               )
             or
             exists (select a.dup_record_id
             from hz_imp_dup_details a, hz_org_contacts b
             where a.party_id = h.party_id
             and a.batch_id = p_batch_id
             and a.record_id = b.org_contact_id
             and b.request_id = p_request_id
               )
          )
        ) ;

    FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
    FND_FILE.put_line(FND_FILE.log,'Details ::: Number of parties inserted to Dup Sets '||SQL%ROWCOUNT);
    FND_FILE.put_line(FND_FILE.log,'Details ::: End time of insert '||to_char(sysdate,'hh24:mi:ss'));

    -- INSERT INTO HZ_DUP_SET_PARTIES, ALL THE WINNERS FROM HZ_DUP_SETS
    -- FOR THE GIVEN BATCH
    insert into hz_dup_set_parties (dup_party_id, dup_set_id,merge_seq_id,
                 merge_batch_id,score,merge_flag, created_by,creation_date,last_update_login,
                 last_update_date,last_updated_by,dup_set_batch_id) --Bug No: 4244529
    select  a.winner_party_id, a.dup_set_id, 0, 0, 100 ,'Y',
                        hz_utility_pub.created_by,hz_utility_pub.creation_date,
                        hz_utility_pub.last_update_login,hz_utility_pub.last_update_date,
                        hz_utility_pub.user_id,a.dup_batch_id --Bug No: 4244529
    from hz_dup_sets a
    where a.dup_batch_id = l_dup_batch_id
    and a.merge_type = 'SAME_PARTY_MERGE';

    FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
    FND_FILE.put_line(FND_FILE.log,'Details ::: Number of parties inserted to Dup Set Parties '||SQL%ROWCOUNT);
    FND_FILE.put_line(FND_FILE.log,'Details ::: End time of insert '||to_char(sysdate,'hh24:mi:ss'));

    FND_FILE.put_line(FND_FILE.log,'Details ::: total merge request count is '
                                                   || l_party_count);

    -- Updating counts to Batch Summary
    -- Party Site Count
    select count(distinct a.dup_record_id) into ps_count
                                     from hz_imp_dup_details a, hz_party_sites b
                                     where a.batch_id = p_batch_id
                                     and a.record_id = b.party_site_id
                                     and b.request_id = p_request_id ;
    update hz_imp_batch_summary h
    set address_merge_requests = ps_count
    where h.batch_id = p_batch_id ;


     -- Contact Point Count
    select count(distinct a.dup_record_id) into cp_count
                                         from hz_imp_dup_details a, hz_contact_points b
                                         where a.batch_id = p_batch_id
                                         and a.record_id = b.contact_point_id
                                         and b.request_id = p_request_id  ;
    update hz_imp_batch_summary h
    set contactpoint_merge_requests =  cp_count
    where h.batch_id = p_batch_id ;



     -- Contact Count
    select count(distinct a.dup_record_id) into c_count
                                       from hz_imp_dup_details a, hz_org_contacts b
                                       where a.batch_id = p_batch_id
                                       and a.record_id = b.org_contact_id
                                       and b.request_id = p_request_id ;

    update hz_imp_batch_summary h
    set contact_merge_requests =  c_count
    where h.batch_id = p_batch_id ;

    -- Total Count
    l_party_count := l_party_count + ps_count + c_count + cp_count ;

    update hz_imp_batch_summary h
    set total_merge_requests = l_party_count
    where h.batch_id = p_batch_id ;

    FND_FILE.put_line(FND_FILE.log,'Details ::: Total Number of merge requests inserted into batch summary table is '
                                                   || l_party_count);


    EXCEPTION
           WHEN OTHERS THEN
                   FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROC' ,'REPORT_INT_TCA_DUP_DETAILS');
                   FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END ;



PROCEDURE interface_tca_dup_id(
                  p_batch_id                   IN number,
                  p_match_rule_id              IN number,
                  p_from_osr                   IN VARCHAR2,
                  p_to_osr                     IN VARCHAR2,
                  p_batch_mode_flag            IN VARCHAR2,
                  x_return_status              OUT NOCOPY     VARCHAR2,
                  x_msg_count                  OUT NOCOPY     NUMBER,
                  x_msg_data                   OUT NOCOPY     VARCHAR2
                 )
 IS
    x_threshold number;
    x_auto_merge_threshold number;
    ret_value number;
    l_pkg_name varchar2(2000);
    anon_str varchar2(255);
BEGIN
        -- initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- stage data into interface tables
        HZ_IMP_DQM_STAGE.pop_int_tca_search_tab( p_batch_id, p_match_rule_id,p_from_osr, p_to_osr,p_batch_mode_flag,
                    x_return_status,x_msg_count,x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
            FND_FILE.put_line(FND_FILE.log,'Staging Unsuccessful - pop_int_tca_search_tab did not return success');
            return;
        END IF;

        -- get the threshold and the auto merge threshold
        select match_score, auto_merge_score into x_threshold, x_auto_merge_threshold
        from hz_match_rules_vl
        where match_rule_id = p_match_rule_id;

        -- get the match rule package
        l_pkg_name := 'HZ_IMP_MATCH_RULE_'||p_match_rule_id;

        -- call the corresponding function in this match rule package, to join based on entities
        -- dictated by the match rule and report results to the hz_imp_dup_parties table
        -- and any other details table
        anon_str := 'begin ' || l_pkg_name || '.interface_tca_join_entities(:p_batch_id,' ||
                      ':p_from_osr,:p_to_osr,:x_threshold,:x_auto_merge_threshold); end;' ;

        EXECUTE IMMEDIATE anon_str USING p_batch_id, p_from_osr, p_to_osr, x_threshold,
                                         x_auto_merge_threshold  ;

        EXCEPTION
           WHEN OTHERS THEN
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROC' ,'INTERFACE_TCA_DUP_ID');
                   FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                   FND_MSG_PUB.ADD;
                   FND_MSG_PUB.Count_And_Get(
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

END ;


PROCEDURE update_party_dqm_action_flag (
    p_batch_id IN number,
    p_cur    IN EntityCur )
is
    l_limit NUMBER := 200;
    l_last_fetch BOOLEAN := FALSE;
    H_POSR CharList ;
    H_POS CharList;
    H_AM_FLAG CharList ;

BEGIN

    -- LOOP THROUGH THE PASSED IN OPEN CURSOR
    LOOP
          FETCH p_cur BULK COLLECT INTO
                H_POSR,
                H_POS,
                H_AM_FLAG
          LIMIT l_limit;

          IF p_cur%NOTFOUND THEN
            l_last_fetch:=TRUE;
          END IF;

          IF H_POSR.COUNT = 0 and l_last_fetch THEN
            EXIT;
          END IF;

          BEGIN
              -- update the interface table
              FORALL I in H_POSR.FIRST..H_POSR.LAST
                UPDATE HZ_IMP_PARTIES_INT A
                SET A.DQM_ACTION_FLAG = DECODE(H_AM_FLAG(I), 'Y','D','P')
                WHERE
                   ( A.PARTY_ORIG_SYSTEM_REFERENCE = H_POSR(I) and
                     A.PARTY_ORIG_SYSTEM = H_POS(I) and
                     A.BATCH_ID = p_batch_id
                     );
          END;

          IF l_last_fetch THEN
          EXIT;

          END IF;
    END LOOP;

    ---------- exception block ---------------
    EXCEPTION
    WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
         FND_MESSAGE.SET_TOKEN('PROC','UPDATE_PARTY_DQM_ACTION_FLAG');
         FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

PROCEDURE update_detail_dqm_action_flag (
    p_entity IN VARCHAR2,
    p_batch_id IN number,
    p_cur    IN EntityCur )
is
    l_limit NUMBER := 200;
    l_last_fetch BOOLEAN := FALSE;
    H_POSR CharList ;
    H_POS CharList;

BEGIN

    -- LOOP THROUGH THE PASSED IN OPEN CURSOR
    LOOP
          FETCH p_cur BULK COLLECT INTO
                H_POSR,
                H_POS
          LIMIT l_limit;

          IF p_cur%NOTFOUND THEN
            l_last_fetch:=TRUE;
          END IF;

          IF H_POSR.COUNT = 0 and l_last_fetch THEN
            EXIT;
          END IF;

          BEGIN
              -- update the corresponding detail interface table
              IF p_entity = 'PARTY_SITES'
              THEN
                      FORALL I in H_POSR.FIRST..H_POSR.LAST
                        UPDATE HZ_IMP_ADDRESSES_INT A
                        SET A.DQM_ACTION_FLAG = 'P'
                        WHERE
                           ( A.SITE_ORIG_SYSTEM_REFERENCE = H_POSR(I) and
                             A.SITE_ORIG_SYSTEM = H_POS(I) and
                             A.BATCH_ID = p_batch_id
                             );

               ELSIF p_entity = 'CONTACT_POINTS'
               THEN
                     FORALL I in H_POSR.FIRST..H_POSR.LAST
                        UPDATE HZ_IMP_CONTACTPTS_INT A
                        SET A.DQM_ACTION_FLAG = 'P'
                        WHERE
                           ( A.CP_ORIG_SYSTEM_REFERENCE = H_POSR(I) and
                             A.CP_ORIG_SYSTEM = H_POS(I) and
                             A.BATCH_ID = p_batch_id
                             );

                ELSIF p_entity = 'CONTACTS'
                THEN
                         FORALL I in H_POSR.FIRST..H_POSR.LAST
                                UPDATE HZ_IMP_CONTACTS_INT A
                                SET A.DQM_ACTION_FLAG = 'P'
                                WHERE
                                   ( A.CONTACT_ORIG_SYSTEM_REFERENCE = H_POSR(I) and
                                     A.CONTACT_ORIG_SYSTEM = H_POS(I) and
                                     A.BATCH_ID = p_batch_id
                                     );

                END IF;

          END;

          IF l_last_fetch THEN
          EXIT;

          END IF;
    END LOOP;


     ---------- exception block ---------------
    EXCEPTION
    WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
         FND_MESSAGE.SET_TOKEN('PROC','UPDATE_DETAIL_DQM_ACTION_FLAG');
         FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM );
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;


PROCEDURE  final_process_int_tca_dup_id(p_batch_id IN number)
IS
BEGIN
       -- Potential would mean party matches that do not pass the Automerge threshold
       -- Duplicates would mean party matches that do pass the Automerge threshold

       -- update dup party counts to hz_imp_batch_summary table
        update hz_imp_batch_summary h
            set dup_parties =
                        (select count (distinct party_id)
                         from hz_imp_dup_parties
                         where batch_id = p_batch_id
                         and auto_merge_flag = 'Y'
                              )
        where
            h.batch_id = p_batch_id ;


        -- update potential dup party counts to hz_imp_batch_summary table
        update hz_imp_batch_summary h
            set potential_dup_parties =
                        (select count (distinct party_id)
                         from hz_imp_dup_parties
                         where batch_id = p_batch_id
                         and auto_merge_flag = 'N'
                              )
        where
            h.batch_id = p_batch_id ;

       -- update potential dup party site counts to hz_imp_batch_summary table
         update hz_imp_batch_summary h
         set potential_dup_addresses =
         (select count(1) from
            (select distinct record_id
            from hz_imp_dup_details
            where batch_id =  p_batch_id
            and entity = 'PARTY_SITES'
            )
          )
          where
          h.batch_id = p_batch_id ;


          -- update potential dup contacts counts to hz_imp_batch_summary table
         update hz_imp_batch_summary h
         set potential_dup_contacts =
         (select count(1) from
            (select distinct record_id
            from hz_imp_dup_details
            where batch_id =  p_batch_id
            and entity = 'CONTACTS'
            )
          )
          where
          h.batch_id = p_batch_id ;


          -- update potential contact point counts to hz_imp_batch_summary table
         update hz_imp_batch_summary h
         set potential_dup_contactpoints =
         (select count(1) from
            (select distinct record_id
            from hz_imp_dup_details
            where batch_id =  p_batch_id
            and entity = 'CONTACT_POINTS'
            )
          )
          where
          h.batch_id = p_batch_id ;

         EXCEPTION
         WHEN OTHERS THEN
                   FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROC' ,'FINAL_PROCESS_INT_TCA_DUP_ID');
                   FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END;


PROCEDURE interface_tca_sanitize_report(
                 p_batch_id                   IN      NUMBER,
                 p_match_rule_id              IN      NUMBER,
                 p_request_id                 IN      NUMBER,
                 x_dup_batch_id               OUT NOCOPY     NUMBER,
                 x_return_status              OUT NOCOPY     VARCHAR2,
                 x_msg_count                  OUT NOCOPY     NUMBER,
                 x_msg_data                   OUT NOCOPY     VARCHAR2
                 )
IS
x_party_count NUMBER := 0;
BEGIN
        -- initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
        FND_FILE.put_line(FND_FILE.log,'Entering interface_tca_sanitize_report ');

        -- report all the tca parties that find duplicates in the interface
        report_int_tca_dup_parties (p_batch_id, p_match_rule_id, p_request_id, x_dup_batch_id, x_party_count);

        -- report all the tca parties that find duplicate detail information in interface
        report_int_tca_dup_details (p_batch_id, p_match_rule_id, p_request_id, x_dup_batch_id, x_party_count);


        EXCEPTION
           WHEN OTHERS THEN
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROC' ,'INTERFACE_TCA_SANITIZE_REPORT');
                   FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                   FND_MSG_PUB.ADD;
                   FND_MSG_PUB.Count_And_Get(
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);


END;


PROCEDURE  report_int_dup_party_osrs (
                p_batch_id              IN NUMBER
)
IS
BEGIN
        -- FIRST, REPORT WINNER OSRS TO INTERFACE DEDUP RESULTS
        -- THESE ARE ALL PRECISELY THE ORD_F_OSRs IN HZ_INT_DUP_RESULTS_GT WHICH ARE NOT
        -- ORD_T_OSRs OF ANY ROW AND OCCUR AT ODD LEVELS IN THE CONNECT BY.

        ----------------------------------------------------
        --- EXAMPLE :
        -- 1 2  LEVEL 1
        -- 2 3  LEVEL 2
        -- 3 4  LEVEL 3
        -- 1 7  LEVEL 1
        -- WOULD RESULT IN 1 AND 2 BEING CHOSEN AS WINNER PARTIES
        -- AFTER THE CONNECT BY. SO THE CONNECT BY NOT ONLY CHOOSES
        -- THE WINNER, BUT ALSO MAKES SURE THAT ODD LEVELS ARE TAKEN
        -- INTO ACCOUNT.
        -----------------------------------------------------

        -- first insert winner party osrs, with dup osrs being themselves
        -- into hz_imp_int_dedup_results

        /*
        insert into hz_imp_int_dedup_results ( batch_id, winner_record_osr, winner_record_os,
                                               dup_record_osr, dup_record_os, entity,
                                               score, dup_creation_date, dup_last_update_date
                                               ,created_by,creation_date,last_update_login
                                               ,last_update_date,last_updated_by)

        select p_batch_id, win_party_osr,win_party_os, win_party_osr, win_party_os,
               'PARTY', 0, hz_utility_pub.creation_date, hz_utility_pub.last_update_date
                 ,hz_utility_v2pub.created_by,hz_utility_v2pub.creation_date
                 ,hz_utility_v2pub.last_update_login,hz_utility_v2pub.last_update_date
                 ,hz_utility_v2pub.last_updated_by
        from
        (
        select distinct d.ord_f_osr as win_party_osr, d.f_os as win_party_os, level as levelu
        from hz_int_dup_results d
        start with d.ord_f_osr not in
           (
                select c.ord_t_osr
                from hz_int_dup_results c
           )
        connect by prior ord_t_osr = ord_f_osr
        )
        where mod(levelu, 2) = 1 ;
        */

   FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
   FND_FILE.put_line(FND_FILE.log,'Parties ::: Reporting winners to HZ_IMP_INT_DEDUP_RESULTS ');
   FND_FILE.put_line(FND_FILE.log,'Parties ::: Begin time of insert '||to_char(sysdate,'hh24:mi:ss'));



        -- we use the temporary table hz_int_dup_results_gt, instead of
        -- hz_int_dup_results
        insert into hz_imp_int_dedup_results ( batch_id, winner_record_osr, winner_record_os,
                                               dup_record_osr, dup_record_os, entity,
                                               score, dup_creation_date, dup_last_update_date
                                               ,created_by,creation_date,last_update_login
                                               ,last_update_date,last_updated_by)
        select p_batch_id, win_party_osr,win_party_os, win_party_osr, win_party_os,
               'PARTY', 0, hz_utility_pub.creation_date, hz_utility_pub.last_update_date
                 ,hz_utility_v2pub.created_by,hz_utility_v2pub.creation_date
                 ,hz_utility_v2pub.last_update_login,hz_utility_v2pub.last_update_date
                 ,hz_utility_v2pub.last_updated_by
        from
        (
        select distinct d.ord_f_osr as win_party_osr, d.f_os as win_party_os, level as levelu
        from hz_int_dup_results_gt d
        start with d.ord_f_osr not in
           (
                select c.ord_t_osr
                from hz_int_dup_results_gt c
                where c.batch_id = p_batch_id
           )
           and d.batch_id = p_batch_id
        connect by prior ord_t_osr = ord_f_osr  and prior batch_id = batch_id
        )
        where mod(levelu, 2) = 1 ;

   FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of winner parties inserted to HZ_IMP_INT_DEDUP_RESULTS '||SQL%ROWCOUNT);
   FND_FILE.put_line(FND_FILE.log,'Parties ::: End time of insert '||to_char(sysdate,'hh24:mi:ss'));

   FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
   FND_FILE.put_line(FND_FILE.log,'Parties ::: Reporting duplicate parties to HZ_IMP_INT_DEDUP_RESULTS ');
   FND_FILE.put_line(FND_FILE.log,'Parties ::: Begin time of insert '||to_char(sysdate,'hh24:mi:ss'));


        -- Take inserted winner party osrs from hz_imp_int_dedup_results , join with
        -- hz_int_dup_results_gt and insert the winner, dup pair to hz_imp_int_dedup_results
        insert into hz_imp_int_dedup_results ( batch_id, winner_record_osr, winner_record_os,
                                               dup_record_osr, dup_record_os, entity,
                                               score, dup_creation_date, dup_last_update_date
                                               ,created_by,creation_date,last_update_login
                                               ,last_update_date,last_updated_by)
        select p_batch_id, a.winner_record_osr,a.winner_record_os, b.ord_t_osr, b.t_os,
               'PARTY', b.score, hz_utility_pub.creation_date, hz_utility_pub.last_update_date
               ,hz_utility_v2pub.created_by,hz_utility_v2pub.creation_date
               ,hz_utility_v2pub.last_update_login,hz_utility_v2pub.last_update_date
               ,hz_utility_v2pub.last_updated_by
        from hz_imp_int_dedup_results a, hz_int_dup_results_gt b
        where a.batch_id = p_batch_id and b.batch_id = p_batch_id and a.entity = 'PARTY'
        and b.ord_f_osr = a.winner_record_osr ;

         FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of duplicate parties inserted to HZ_IMP_INT_DEDUP_RESULTS '||SQL%ROWCOUNT);
         FND_FILE.put_line(FND_FILE.log,'Parties ::: End time of insert '||to_char(sysdate,'hh24:mi:ss'));



         FND_FILE.put_line(FND_FILE.log,'Parties ::: Begin time of update for getting import table dates '||to_char(sysdate,'hh24:mi:ss'));

         -- Bug Fix 3588873 :: Need to report the import interface table dates for all the duplicates
         -- We take of the "PARTY" entity here.
         update hz_imp_int_dedup_results a
         set (a.dup_creation_date, a.dup_last_update_date)
              = (select b.creation_date, b.last_update_date
                 from hz_imp_parties_int b
                 where b.batch_id = p_batch_id
                 and b.party_orig_system_reference = a.dup_record_osr
                 and b.party_orig_system = a.dup_record_os
                  )
          where a.entity = 'PARTY' and a.batch_id = p_batch_id ;

        FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of duplicate parties updated in HZ_IMP_INT_DEDUP_RESULTS '||SQL%ROWCOUNT);
        FND_FILE.put_line(FND_FILE.log,'Parties ::: End time of update for getting import table dates '||to_char(sysdate,'hh24:mi:ss'));

--bug 5393826
        FND_FILE.put_line(FND_FILE.log,'Parties ::: Deleting Party Duplicate sets for which no records exist in import party interface table '||to_char(sysdate,'hh24:mi:ss'));

        delete from hz_imp_int_dedup_results a
        where a.entity = 'PARTY'
        and a.batch_id = p_batch_id
        and not exists
             ( select 1
               from hz_imp_parties_int b
               where a.batch_id = b.batch_id
               and a.winner_record_osr = b.party_orig_system_reference
               and a.winner_record_os = b.party_orig_system
              );

       FND_FILE.put_line(FND_FILE.log,'Parties ::: Delete Complete '||to_char(sysdate,'hh24:mi:ss'));
       FND_FILE.put_line(FND_FILE.log,'Parties ::: Number of rows deleted is ' || SQL%ROWCOUNT );
--bug 5393826


        EXCEPTION
        WHEN OTHERS THEN
                   FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROC' ,'REPORT_INT_DUP_PARTY_OSRS');
                   FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END ;



PROCEDURE interface_dup_id_worker(
                  p_batch_id                   IN number,
                  p_match_rule_id              IN number,
                  p_from_osr                   IN VARCHAR2,
                  p_to_osr                     IN VARCHAR2,
                  x_return_status              OUT NOCOPY     VARCHAR2,
                  x_msg_count                  OUT NOCOPY     NUMBER,
                  x_msg_data                   OUT NOCOPY     VARCHAR2
                 )
 IS
    x_threshold number;
    ret_value number;
    anon_str varchar2(255);
    l_pkg_name varchar2(2000);
BEGIN
        -- initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- get the threshold
        select match_score into x_threshold
        from hz_match_rules_vl
        where match_rule_id = p_match_rule_id;

        -- get the match rule package
        l_pkg_name := 'HZ_IMP_MATCH_RULE_'||p_match_rule_id;

        -- call the corresponding function in this match rule package, to join based on entities
        -- dictated by the match rule and do the following
        -- 1. report party dup results to hz_int_dup_results
        -- 2. report detail dup results directly to hz_imp_int_dedup_results

        anon_str := 'begin ' || l_pkg_name || '.interface_join_entities(:p_batch_id,' ||
                      ':p_from_osr,:p_to_osr,:x_threshold); end;' ;

        EXECUTE IMMEDIATE anon_str USING p_batch_id, p_from_osr, p_to_osr, x_threshold ;

        commit;


        EXCEPTION
        WHEN OTHERS THEN
        -- dbms_output.put_line('err '||SQLERRM);
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROC' ,'INTERFACE_DUP_ID_WORKER');
                   FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                   FND_MSG_PUB.ADD;
                   FND_MSG_PUB.Count_And_Get(
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 END ;


PROCEDURE interface_sanitize_report(
                 p_batch_id                   IN NUMBER,
                 p_match_rule_id              IN NUMBER,
                 x_return_status              OUT NOCOPY     VARCHAR2,
                 x_msg_count                  OUT NOCOPY     NUMBER,
                 x_msg_data                   OUT NOCOPY     VARCHAR2
                 )
IS
x_threshold number;
BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FND_FILE.put_line(FND_FILE.log,'------------------------------------------------------------');
    FND_FILE.put_line(FND_FILE.log,'Entering interface_sanitize_report ');



    -- get the threshold for the match rule
    select match_score into x_threshold
    from hz_match_rules_vl
    where match_rule_id = p_match_rule_id;

    -- sanitize party osrs
    sanitize_int_dup_party_osrs (x_threshold, p_batch_id);

    -- report party osrs
    report_int_dup_party_osrs (p_batch_id);

    -- sanitize detail osrs
    sanitize_int_dup_detail_osrs (p_batch_id);

    -- do final processing
    final_process_int_dup_id(p_batch_id);
    EXCEPTION
    WHEN OTHERS THEN
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROC' ,'INTERFACE_SANITIZE_REPORT');
                   FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                   FND_MSG_PUB.ADD;
                   FND_MSG_PUB.Count_And_Get(
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);


END;
 ----------------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------------
 --   MATH RULE COMPILATION
 ----------------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------------


 /**
 * PROCEDURE compile_match_rule
 *
 * DESCRIPTION
 *
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   04-09-2003  Colathur Vijayan       o Created.
 *
 */

--------------------------------------------------------------------------------------
-- compile_match_rule ::: This procedure generates a compiled PLSQL package
--                       spec and body for the given Match Rule (p_match_rule_id).
--                       The name of the generated match rule is
--                       HZ_IMP_MATCH_RULE_<p_match_rule_id>.
--------------------------------------------------------------------------------------

PROCEDURE compile_match_rule (
	    p_match_rule_id	        IN	NUMBER,
        x_return_status         OUT NOCOPY    VARCHAR2,
        x_msg_count             OUT NOCOPY    NUMBER,
        x_msg_data              OUT NOCOPY    VARCHAR2
) IS

   CURSOR check_null_set IS
    SELECT DISTINCT a.entity_name
    FROM hz_match_rule_secondary s, hz_trans_attributes_vl a
    WHERE a.attribute_id = s.attribute_id
    AND s.match_rule_id = p_match_rule_id
    MINUS
    SELECT DISTINCT a.entity_name
    FROM hz_match_rule_primary p, hz_trans_attributes_vl a
    WHERE a.attribute_id = p.attribute_id
    AND p.match_rule_id = p_match_rule_id;

   CURSOR check_inactive IS
    SELECT 1
    FROM hz_match_rule_primary p, hz_primary_trans pt, hz_trans_functions_vl f
    WHERE p.match_rule_id = p_match_rule_id
    AND pt.PRIMARY_ATTRIBUTE_ID = p.PRIMARY_ATTRIBUTE_ID
    AND f.function_id = pt.function_id
    AND nvl(f.ACTIVE_FLAG,'Y') = 'N'
    UNION
    SELECT 1
    FROM hz_match_rule_secondary s, hz_secondary_trans pt, hz_trans_functions_vl f
    WHERE s.match_rule_id = p_match_rule_id
    AND pt.SECONDARY_ATTRIBUTE_ID = s.SECONDARY_ATTRIBUTE_ID
    AND f.function_id = pt.function_id
    AND nvl(f.ACTIVE_FLAG,'Y') = 'N';

-- Local variable declarations
    l_tmp VARCHAR2(255);
    l_batch_flag VARCHAR2(1);
    l_package_name VARCHAR2(2000);

BEGIN

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize the compiled package name
  l_package_name := 'HZ_IMP_MATCH_RULE_'||p_match_rule_id;

  -- Initialize message stack
  FND_MSG_PUB.initialize;

  BEGIN
    -- Verify that the match rule exists
    SELECT 1 INTO l_batch_flag
    FROM HZ_MATCH_RULES_VL
    WHERE match_rule_id = p_match_rule_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_STAGE_NO_RULE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END;


  BEGIN

 /*  Added to check that acquisition has at least one attribute for each entity defined in scoring.
     Added update statements since compile_match_rule is public api and commented unnecessary updates in
     compile_all_rules and compile_all_rules_nolog.
 */
     OPEN  check_null_set;
      FETCH check_null_set INTO l_tmp;
      IF check_null_set%FOUND THEN
        CLOSE  check_null_set;
          BEGIN
            EXECUTE IMMEDIATE 'DROP PACKAGE HZ_IMP_MATCH_RULE_'||p_match_rule_id;
          EXCEPTION
            WHEN OTHERS THEN
             NULL;
          END;
          fnd_message.set_name('AR','HZ_SCORING_NO_ACQUISITION');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
     CLOSE check_null_set;
  END;

/* Check if match rule has any inactive transformations */
  OPEN check_inactive;
  FETCH check_inactive INTO l_tmp;
  IF check_inactive%FOUND THEN
    CLOSE  check_inactive;
      BEGIN
        EXECUTE IMMEDIATE 'DROP PACKAGE HZ_IMP_MATCH_RULE_'||p_match_rule_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      fnd_message.set_name('AR','HZ_MR_HAS_INACTIVE_TX');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE check_inactive;

    -- Generate and compile match rule package spec
  HZ_GEN_PLSQL.new(l_package_name, 'PACKAGE');
  HZ_DQM_MR_PVT.gen_pkg_spec(l_package_name, p_match_rule_id);
  HZ_GEN_PLSQL.compile_code;

  -- Generate and compile match rule package body
  HZ_GEN_PLSQL.new(l_package_name, 'PACKAGE BODY');
  HZ_DQM_MR_PVT.gen_pkg_body_tca_join(l_package_name, p_match_rule_id);
  HZ_DQM_MR_PVT.gen_pkg_body_int_tca_join(l_package_name, p_match_rule_id);
  HZ_DQM_MR_PVT.gen_pkg_body_int_join(l_package_name, p_match_rule_id);
  HZ_DQM_MR_PVT.gen_footer;
  HZ_GEN_PLSQL.compile_code;


   --Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_encoded => FND_API.G_FALSE,
    p_count => x_msg_count,
    p_data  => x_msg_data);

  UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'C' WHERE MATCH_RULE_ID = p_match_rule_id;
  COMMIT;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
    x_return_status := FND_API.G_RET_STS_ERROR;
    UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'U' WHERE MATCH_RULE_ID = p_match_rule_id;
    COMMIT;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'U' WHERE MATCH_RULE_ID = p_match_rule_id;
    COMMIT;
  WHEN OTHERS THEN

    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC','compile_match_rule');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;

    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'U' WHERE MATCH_RULE_ID = p_match_rule_id;
    COMMIT;
END;


/**********************************************************************************
 **********************************************************************************
 WE SHALL STUB THESE OUT NOW AND USE THESE ALGOS , IN THE FUTURE WHEN WE DEAL WITH
 TRANSITIVITY, FOR AUTO MERGE !!!!!!!!!!!
 **********************************************************************************

------------------------------
-- identify_dup_pairs
-----------------------------

FUNCTION identify_dup_pairs
RETURN NUMBER
IS
  l_yn number ;
BEGIN
 -- Update all intersecting dup pairs viz, (a,b) intersects with (c,d) if one of
 -- a = c, a = d, b = c, b = d is true.
 update hz_dup_results a
 set flag = 'D'
 where exists
    (select 1
     from hz_dup_results b
     where ( a.fid = b.fid and a.tid <> b.tid)
             or (a.tid = b.tid and a.fid <> b.fid)
             or (a.fid = b.tid)
             or (a.tid = b.fid)
     ) ;
  return 0 ;
END identify_dup_pairs ;


PROCEDURE  sanitize_dup_parties_future (
                p_threshold             IN NUMBER,
 	            p_init_msg_list			IN  VARCHAR2,
 	            x_return_status			OUT NOCOPY VARCHAR2,
                x_msg_count				OUT NOCOPY NUMBER,
                x_msg_data				OUT NOCOPY VARCHAR2
)
IS
BEGIN

    ----------------------------------------------------------------------------------------------
    -- Step 1: SANITIZE THE OCCURENCE OF ALL THE REVERSED PAIRS FROM STEP 1
    -- AND ALSO APPLY THE THRESHOLD.
    ----------------------------------------------------------------------------------------------

    -- At the end of this, we would have the following:
    -- The pair with fid < tid, if both the pairs have the same score
    -- The pair with the higher score, if in case, the pairs of different scores.


          -- delete the smallest source, if scores are equal
          delete from hz_dup_results a
          where
          a.score < p_threshold
          or
          (exists
            (Select 1 from hz_dup_results b
             where a.fid=b.tid and b.fid=a.tid and a.score = b.score)
             and a.fid < a.tid );

          -- delete the one with the smallest score, if scores are not equal
          delete from hz_dup_results a
          where
          a.score < p_threshold
          or
          exists
            (Select 1 from hz_dup_results b
             where a.fid=b.tid and b.fid=a.tid and a.score < b.score) ;

        ------------------------------------------------------------------------------------------------------
        -- Step 2 - IDENTIFY DUP SETS AND REPORT THEM APPROPRIATELY, TO ANOTHER TEMP TABLE
        --          THAT WILL BE THE BASIS FOR REPORTING TO HZ_DUP_SETS AND HZ_DUP_SET_PARTIES
        ------------------------------------------------------------------------------------------------------

        -- Now call the stored program
          identify_dup_sets('T',x_return_status,x_msg_count,x_msg_data);

END;




FUNCTION find_duplicates (p_fid number, p_tid number, p_dup_set_id number)
RETURN NUMBER
IS
  ret_val number;
  master_party_id varchar2(2000) ;
  rowCount   number ;
  x_dup_set_id number;

CURSOR master_dup_cur
IS
-- Get a row that intersects with the passed in fid and tid and already has
-- the stamp of the master party id
select a.fid, a.tid , a.flag, a.dup_set_id
from hz_dup_results a
where (a.flag <> 'D') and
(a.fid = p_fid or a.fid = p_tid or a.tid = p_fid or a.tid = p_tid) and
rownum = 1
order by a.flag ;

master_dup_cur_rec master_dup_cur%rowtype;

BEGIN
  rowCount := 0;

    -- Find the Master if it exists
    OPEN master_dup_cur ;
    LOOP
       FETCH master_dup_cur INTO master_dup_cur_rec;
       -- if you cannot find anything, get the hell out of here.
       EXIT WHEN master_dup_cur%NOTFOUND  ;

       -- If you can get this far, store the following,
       -- in order to use them, in the logic, outside the loop.
       master_party_id := master_dup_cur_rec.flag ;
       x_dup_set_id := master_dup_cur_rec.dup_set_id ;
       rowCount := rowCount + 1;
    END LOOP;
    CLOSE master_dup_cur;

    -- If Master does not exist, make the passed in fid to be the Master and
    -- create the dup set id from sequence
    IF rowCount = 0
    THEN
         master_party_id := to_char(p_fid);
         -- get the sequence from HZ_DUP_SETS
         SELECT HZ_MERGE_BATCH_S.nextval INTO x_dup_set_id FROM DUAL;
    END IF;

    -- Stamp all intersecting rows (including the passed in row itself), that still have a 'D' flag,
    -- with the stamp of the Master and also populate the dup set id column
       update hz_dup_results a
       set flag = master_party_id, dup_set_id = x_dup_set_id
       where (a.flag = 'D') and
       (a.fid = p_fid or a.fid = p_tid or a.tid = p_fid or a.tid = p_tid) ;

  return 0 ;
END find_duplicates ;

------------------------------
-- stamp_trivial_dup_sets
-----------------------------

FUNCTION stamp_trivial_dup_sets
RETURN NUMBER
IS
BEGIN

    -- Stamp the dup set id column of all rows with flag = 'ND', with sequence obtained from
    -- HZ_DUP_SETS
       update hz_dup_results a
       set dup_set_id = HZ_MERGE_BATCH_S.nextval
       where a.flag = 'ND' ;
    return 0 ;
END stamp_trivial_dup_sets ;


------------------------------
-- stamp_non_trivial_dup_sets
-----------------------------

FUNCTION stamp_non_trivial_dup_sets
RETURN NUMBER
IS
  ret_val number ;
  rowCount   number;
  temp_fid number;
  temp_tid number;
  temp_dup_set_id number;
  temp_rowid rowid;
CURSOR dup_set_cur
IS
select fid, tid, dup_set_id, rowid
from hz_dup_results
where flag = 'D'
and rownum = 1
order by flag ;

dup_set_cur_rec  dup_set_cur%rowtype;
BEGIN

  rowCount := 0 ;


  -- Cursor gets at most one row or no rows.
  -- Also, note that the cursor would not return any row, that is stamped as 'ND' --
  -- the ones for which the dupset, need not have to be formed, explicitly.
    OPEN dup_set_cur ;
    LOOP
       FETCH dup_set_cur INTO dup_set_cur_rec;
       EXIT WHEN dup_set_cur%NOTFOUND;

       -- If you can get this far, do the following
       -- in order to use in the logic outside the loop.

       temp_fid := dup_set_cur_rec.fid;
       temp_tid := dup_set_cur_rec.tid;
       temp_dup_set_id := dup_set_cur_rec.dup_set_id;
       temp_rowid := dup_set_cur_rec.rowid;
       rowCount := rowCount + 1;

    END LOOP;
    CLOSE dup_set_cur ;

    -- Do Recursion, only when the rowcount is atleast 1
    -- No point in doing anything, if we don't find any rows with the 'D' flag.
    IF rowCount > 0
    THEN
        -- starting from the fetched row, identify all duplicates and form the dup set.
        -- note that find_duplicates, will find all intersecting rows corresponding to
        -- the fetched row. since dup sets may be spanned across different rows, it is
        -- quite possible for find_duplicates to find the actual dupset in multiple fetches.
        ret_val := find_duplicates(temp_fid, temp_tid, temp_dup_set_id );

        -- recursion continues for finding the next dupset
        ret_val := stamp_non_trivial_dup_sets ;
     END IF;

    return 0 ;
END stamp_non_trivial_dup_sets ;


------------------------------
-- report_duplicates
-----------------------------

FUNCTION report_duplicates (p_batch_id number, p_match_rule_id number)
RETURN NUMBER
IS
x_auto_merge_threshold number;
BEGIN

           x_auto_merge_threshold := get_auto_merge_threshold(p_match_rule_id);

           ------------------------------------------------------
           -- Step1: Report trivial dup sets
           ------------------------------------------------------

           -- Insert winner party into HZ_DUP_SETS
           insert into hz_dup_sets ( dup_set_id, dup_batch_id, winner_party_id,
           status, merge_type, created_by, creation_date, last_update_login,
           last_update_date, last_updated_by)
           select dup_set_id, p_batch_id, fid,
                    'SYSBATCH', 'PARTY_MERGE', hz_utility_pub.created_by, hz_utility_pub.creation_date,
                     hz_utility_pub.last_update_login, hz_utility_pub.last_update_date,
                     hz_utility_pub.user_id
                     from hz_dup_results
                     where flag = 'ND' ;

            -- Insert winner and its only duplicate, into HZ_DUP_SET_PARTIES
            insert into hz_dup_set_parties (dup_party_id,dup_set_id,merge_seq_id,
             merge_batch_id,score,merge_flag,created_by,creation_date,last_update_login,
             last_update_date,last_updated_by,dup_set_batch_id) --Bug No: 4244529
            select fid, dup_set_id, 0, p_batch_id, score, decode( sign(score - x_auto_merge_threshold),-1,'N','Y'),
                    hz_utility_pub.created_by,hz_utility_pub.creation_date,
                    hz_utility_pub.last_update_login,hz_utility_pub.last_update_date,
                    hz_utility_pub.user_id,p_batch_id --Bug No: 4244529
            from hz_dup_results
            where flag = 'ND';

            insert into hz_dup_set_parties (dup_party_id,dup_set_id,merge_seq_id,
             merge_batch_id,score,merge_flag, created_by,creation_date,last_update_login,
             last_update_date,last_updated_by,dup_set_batch_id) --Bug No: 4244529
            select tid, dup_set_id, 0,p_batch_id, score,decode( sign(score - x_auto_merge_threshold),-1,'N','Y'),
                    hz_utility_pub.created_by,hz_utility_pub.creation_date,
                    hz_utility_pub.last_update_login,hz_utility_pub.last_update_date,
                    hz_utility_pub.user_id,p_batch_id --Bug No: 4244529
            from hz_dup_results
            where flag = 'ND';

            ------------------------------------------------------
           -- Step2: Report non trivial dup sets
           ------------------------------------------------------

           -- Insert winner party into HZ_DUP_SETS
           insert into hz_dup_sets ( dup_set_id, dup_batch_id, winner_party_id,
           status, merge_type, created_by, creation_date, last_update_login,
           last_update_date, last_updated_by)
           select distinct dup_set_id, p_batch_id, flag ,
                    'SYSBATCH', 'PARTY_MERGE', hz_utility_pub.created_by, hz_utility_pub.creation_date,
                     hz_utility_pub.last_update_login, hz_utility_pub.last_update_date,
                     hz_utility_pub.user_id
                     from hz_dup_results
                     where flag <> 'ND' ;

            -- Insert winner party and all its duplicates into HZ_DUP_SET_PARTIES

            insert into hz_dup_set_parties (dup_party_id,dup_set_id,merge_seq_id,
             merge_batch_id,score,merge_flag, created_by,creation_date,last_update_login,
             last_update_date,last_updated_by,dup_set_batch_id) --Bug No: 4244529
            select distinct to_number(flag), dup_set_id, 0, p_batch_id, score ,decode( sign(score - x_auto_merge_threshold),-1,'N','Y'),
                    hz_utility_pub.created_by,hz_utility_pub.creation_date,
                    hz_utility_pub.last_update_login,hz_utility_pub.last_update_date,
                    hz_utility_pub.user_id,p_batch_id --Bug No: 4244529
            from hz_dup_results
            where flag <> 'ND'
            union
            select distinct fid, dup_set_id, 0, p_batch_id, score ,decode( sign(score - x_auto_merge_threshold),-1,'N','Y'),
                    hz_utility_pub.created_by,hz_utility_pub.creation_date,
                    hz_utility_pub.last_update_login,hz_utility_pub.last_update_date,
                    hz_utility_pub.user_id,p_batch_id --Bug No: 4244529
            from hz_dup_results
            where flag <> 'ND'
            union
            select distinct tid, dup_set_id, 0, p_batch_id, score ,decode( sign(score - x_auto_merge_threshold),-1,'N','Y'),
                    hz_utility_pub.created_by,hz_utility_pub.creation_date,
                    hz_utility_pub.last_update_login,hz_utility_pub.last_update_date,
                    hz_utility_pub.user_id,p_batch_id --Bug No: 4244529
            from hz_dup_results
            where flag <> 'ND' ;

  return 0 ;
  END report_duplicates ;


/**
 * PROCEDURE identify_dup_sets
 *
 * DESCRIPTION
 *
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   04-09-2003  Colathur Vijayan       o Created.
 *


--------------------------------------------------------------------------------------
-- identify_dup_sets ::: This procedure would take a table containing pairs of duplicate
--                     party ids, create dupsets by clusteriing all duplicates under
--                     a master party id, by a smart update of an existing column
--------------------------------------------------------------------------------------
PROCEDURE identify_dup_sets (
-- input parameters
 	p_init_msg_list			IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
-- output parameters
    x_return_status			OUT NOCOPY VARCHAR2,
    x_msg_count				OUT NOCOPY NUMBER,
    x_msg_data				OUT NOCOPY VARCHAR2
) IS
  ret_value NUMBER;

  BEGIN

   -- Identify all duplicate pairs, by stamping them with flag 'D'
   ret_value := identify_dup_pairs ;


  -- Identify all non-trivial dupsets, by stamping them with flag = master party id of the dup set
   -- and the dup set id column with the sequence generated from HZ_DUP_SETS
   ret_value := stamp_non_trivial_dup_sets ;

   -- Stamp the dup set id column of all trivial dup sets with the sequence
   -- generated from HZ_DUP_SETS
   ret_value := stamp_trivial_dup_sets ;


   -- standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);


END identify_dup_sets ;
*********************************************************************************************************************/


END; -- Package Body HZ_DQM_DUP_ID_PKG

/
