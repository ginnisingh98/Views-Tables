--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_AGING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_AGING_PVT" AS
/* $Header: ozfvcagb.pls 120.2.12010000.2 2010/02/22 05:10:26 hbandi ship $ */

G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

--------------------------------------------------------------------------------
PROCEDURE insert_aging_dates(
   p_bucket_id           IN  NUMBER,
   p_bucket_line_id      IN  NUMBER,
   p_bucket_sequence     IN  NUMBER,
   p_bucket_type         IN  VARCHAR2,
   p_bucket_date         IN  DATE,
   p_condition_type      IN  VARCHAR2,
   x_return_status       OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   -- insert data
   INSERT INTO ozf_aging_bucket_dates (
      aging_bucket_id,
      aging_bucket_line_id,
      bucket_sequence_num,
      bucket_type,
      bucket_date,
      condition_type
   ) VALUES (
      p_bucket_id,
      p_bucket_line_id,
      p_bucket_sequence,
      p_bucket_type,
      p_bucket_date,
      p_condition_type
   );

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_error;
END;

--------------------------------------------------------------------------------
PROCEDURE populate_aging_dates(
   p_bucket_id       IN  NUMBER,
   p_bucket_line_id  IN  NUMBER,
   p_bucket_sequence IN  NUMBER,
   p_bucket_type     IN  VARCHAR2,
   p_days_start      IN  NUMBER,
   p_days_to         IN  NUMBER,
   p_seq_type        IN  VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
l_type               VARCHAR2(30);
l_high_val           NUMBER := 500;
l_return_status      VARCHAR2(1);
l_bucket_date        DATE;
l_bucket_date_range  NUMBER;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

/*
   FND_PROFILE.get( 'bucket_date_range'
                  , l_high_val
                  );
*/

/*------------------------------------------------------------
 * Claim Aging Calculating rule:
 * bucket type = 'CURRENT' claim_date >= sysdate + dyas_start
 *                         claim_date <= sysdate + dayd_to
 * bucket type = 'PAST' due_date <= sysdate - ABS(dyas_start)
 *                      due_date >= sysdate - ABS(dyas_to)
 * bucket type = 'FUTURE' due_date >= sysdate + ABS(dyas_start)
 *                        due_date <= sysdate + ABS(dyas_to)
 *-----------------------------------------------------------*/
   l_bucket_date_range := ABS(p_days_start - p_days_to);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Aging Bucket: Date Range = '|| l_bucket_date_range);

   -- start of Bugfix 5143538
   -- Absolute value of days must be added for past and future to support negatives
   IF p_seq_type = 'M' OR
      l_bucket_date_range < l_high_val THEN
      l_type := 'EQ';
      FOR i in p_days_start..p_days_to LOOP
         IF p_bucket_type = 'PAST' THEN
            l_bucket_date := sysdate - ABS(i);
         ELSIF p_bucket_type = 'CURRENT' OR
               p_bucket_type = 'FUTURE' THEN
            l_bucket_date := sysdate + ABS(i);
         END IF;
         insert_aging_dates(
            p_bucket_id       => p_bucket_id,
            p_bucket_line_id  => p_bucket_line_id,
            p_bucket_sequence => p_bucket_sequence,
            p_bucket_type     => p_bucket_type,
            p_bucket_date     => l_bucket_date,
            p_condition_type  => l_type,
            x_return_status   => l_return_status
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         END IF;
      END LOOP;
   ELSE
      IF p_seq_type = 'L' THEN
         --l_type := 'GT';
         IF p_bucket_type = 'PAST' THEN
            l_type := 'LT';
            l_bucket_date := sysdate - ABS(p_days_start);
         ELSIF p_bucket_type = 'CURRENT' OR
               p_bucket_type = 'FUTURE' THEN
            l_type := 'GT';
            l_bucket_date := sysdate + ABS(p_days_start);
         END IF;

         insert_aging_dates(
            p_bucket_id       => p_bucket_id,
            p_bucket_line_id  => p_bucket_line_id,
            p_bucket_sequence => p_bucket_sequence,
            p_bucket_type     => p_bucket_type,
            p_bucket_date     => l_bucket_date,
            p_condition_type  => l_type,
            x_return_status   => l_return_status
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         END IF;
      ELSIF p_seq_type = 'F' THEN
         --l_type := 'LT';
         IF p_bucket_type = 'PAST' THEN
            l_type := 'LT';
            l_bucket_date := sysdate - ABS(p_days_to);
         ELSIF p_bucket_type = 'CURRENT' THEN
               l_type := 'LT';
               l_bucket_date := sysdate + p_days_to;
         ELSIF  p_bucket_type = 'FUTURE' THEN
               l_type := 'GT';
               l_bucket_date := sysdate + ABS(p_days_to);
         END IF;
         -- end of Bugfix 5143538

         insert_aging_dates(
            p_bucket_id       => p_bucket_id,
            p_bucket_line_id  => p_bucket_line_id,
            p_bucket_sequence => p_bucket_sequence,
            p_bucket_type     => p_bucket_type,
            p_bucket_date     => l_bucket_date,
            p_condition_type  => l_type,
            x_return_status   => l_return_status
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         END IF;
      END IF;
   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
END;

--------------------------------------------------------------------------------
PROCEDURE populate_aging_summary(
   x_return_status   OUT NOCOPY  VARCHAR2
)
IS
/*------------------------------------------------------------
 * Claim Aging Calculating rule:
 * bucket type = 'CURRENT' claim_date >= sysdate + dyas_start
 *                         claim_date <= sysdate + dayd_to
 * bucket type = 'PAST' due_date <= sysdate - ABS(dyas_start)
 *                      due_date >= sysdate - ABS(dyas_to)
 * bucket type = 'FUTURE' due_date >= sysdate + ABS(dyas_start)
 *                        due_date <= sysdate + ABS(dyas_to)
 *-----------------------------------------------------------*/
 --modified for Bugfix 5143538 dates are truncated and then compared with bucket dates
CURSOR aging_summary_csr IS
SELECT c.cust_account_id cust_account_id
,      b.aging_bucket_id aging_bucket_id
,      b.aging_bucket_line_id aging_bucket_line_id
,      b.bucket_sequence_num bucket_sequence_num
,      c.org_id
,      SUM(c.acctd_amount) amount
FROM   ozf_claims c
,      ozf_aging_bucket_dates b
WHERE  TRUNC(c.claim_date, 'DD') = TRUNC(b.bucket_date, 'DD')
AND    b.condition_type = 'EQ'
AND    b.bucket_type = 'CURRENT'
--AND    c.status_code IN ('NEW', 'OPEN', 'PENDING_APPROVAL', 'COMPLETE', 'APPROVED')
AND    c.status_code IN ('NEW', 'OPEN', 'COMPLETE', 'REJECTED')
GROUP BY c.cust_account_id
,      b.aging_bucket_id
,      b.aging_bucket_line_id
,      b.bucket_sequence_num
,      c.org_id
UNION ALL
SELECT c.cust_account_id cust_account_id
,      b.aging_bucket_id aging_bucket_id
,      b.aging_bucket_line_id aging_bucket_line_id
,      b.bucket_sequence_num bucket_sequence_num
,      c.org_id
,      SUM(c.acctd_amount) amount
FROM   ozf_claims c
,      ozf_aging_bucket_dates b
WHERE  TRUNC(c.claim_date, 'DD') <= TRUNC(b.bucket_date, 'DD')
AND    b.condition_type = 'LT'
AND    b.bucket_type = 'CURRENT'
--AND    c.status_code IN ('NEW', 'OPEN', 'PENDING_APPROVAL', 'COMPLETE', 'APPROVED')
AND    c.status_code IN ('NEW', 'OPEN', 'COMPLETE', 'REJECTED')
GROUP BY c.cust_account_id
,      b.aging_bucket_id
,      b.aging_bucket_line_id
,      b.bucket_sequence_num
,      c.org_id
UNION ALL
SELECT c.cust_account_id cust_account_id
,      b.aging_bucket_id aging_bucket_id
,      b.aging_bucket_line_id aging_bucket_line_id
,      b.bucket_sequence_num bucket_sequence_num
,      c.org_id
,      SUM(c.acctd_amount) amount
FROM   ozf_claims c
,      ozf_aging_bucket_dates b
WHERE  TRUNC(c.claim_date, 'DD') >= TRUNC(b.bucket_date , 'DD')
AND    b.condition_type = 'GT'
AND    b.bucket_type = 'CURRENT'
--AND    c.status_code IN ('NEW', 'OPEN', 'PENDING_APPROVAL', 'COMPLETE', 'APPROVED')
AND    c.status_code IN ('NEW', 'OPEN', 'COMPLETE', 'REJECTED')
GROUP BY c.cust_account_id
,      b.aging_bucket_id
,      b.aging_bucket_line_id
,      b.bucket_sequence_num
,      c.org_id
UNION ALL
SELECT c.cust_account_id cust_account_id
,      b.aging_bucket_id aging_bucket_id
,      b.aging_bucket_line_id aging_bucket_line_id
,      b.bucket_sequence_num bucket_sequence_num
,      c.org_id
,      SUM(c.acctd_amount) amount
FROM   ozf_claims c
,      ozf_aging_bucket_dates b
WHERE  TRUNC(c.due_date, 'DD') = TRUNC(b.bucket_date, 'DD')
AND    b.condition_type = 'EQ'
AND    b.bucket_type = 'PAST'
--AND    c.status_code IN ('NEW', 'OPEN', 'PENDING_APPROVAL', 'COMPLETE', 'APPROVED')
AND    c.status_code IN ('NEW', 'OPEN', 'COMPLETE', 'REJECTED')
GROUP BY c.cust_account_id
,      b.aging_bucket_id
,      b.aging_bucket_line_id
,      b.bucket_sequence_num
,      c.org_id
UNION ALL
SELECT c.cust_account_id cust_account_id
,      b.aging_bucket_id aging_bucket_id
,      b.aging_bucket_line_id aging_bucket_line_id
,      b.bucket_sequence_num bucket_sequence_num
,      c.org_id
,      SUM(c.acctd_amount) amount
FROM   ozf_claims c
,      ozf_aging_bucket_dates b
WHERE  TRUNC(c.due_date, 'DD') <= TRUNC(b.bucket_date , 'DD')
AND    b.condition_type = 'LT'
AND    b.bucket_type = 'PAST'
--AND    c.status_code IN ('NEW', 'OPEN', 'PENDING_APPROVAL', 'COMPLETE', 'APPROVED')
AND    c.status_code IN ('NEW', 'OPEN', 'COMPLETE', 'REJECTED')
GROUP BY c.cust_account_id
,      b.aging_bucket_id
,      b.aging_bucket_line_id
,      b.bucket_sequence_num
,      c.org_id
UNION ALL
SELECT c.cust_account_id cust_account_id
,      b.aging_bucket_id aging_bucket_id
,      b.aging_bucket_line_id aging_bucket_line_id
,      b.bucket_sequence_num bucket_sequence_num
,      c.org_id
,      SUM(c.acctd_amount) amount
FROM   ozf_claims c
,      ozf_aging_bucket_dates b
WHERE  TRUNC(c.due_date, 'DD') >= TRUNC(b.bucket_date , 'DD')
AND    b.condition_type = 'GT'
AND    b.bucket_type = 'PAST'
--AND    c.status_code IN ('NEW', 'OPEN', 'PENDING_APPROVAL', 'COMPLETE', 'APPROVED')
AND    c.status_code IN ('NEW', 'OPEN', 'COMPLETE', 'REJECTED')
GROUP BY c.cust_account_id
,      b.aging_bucket_id
,      b.aging_bucket_line_id
,      b.bucket_sequence_num
,      c.org_id
UNION ALL
SELECT c.cust_account_id cust_account_id
,      b.aging_bucket_id aging_bucket_id
,      b.aging_bucket_line_id aging_bucket_line_id
,      b.bucket_sequence_num bucket_sequence_num
,      c.org_id
,      SUM(c.acctd_amount) amount
FROM   ozf_claims c
,      ozf_aging_bucket_dates b
WHERE  TRUNC(c.due_date, 'DD') = TRUNC(b.bucket_date, 'DD')
AND    b.condition_type = 'EQ'
AND    b.bucket_type = 'FUTURE'
--AND    c.status_code IN ('NEW', 'OPEN', 'PENDING_APPROVAL', 'COMPLETE', 'APPROVED')
AND    c.status_code IN ('NEW', 'OPEN', 'COMPLETE', 'REJECTED')
GROUP BY c.cust_account_id
,      b.aging_bucket_id
,      b.aging_bucket_line_id
,      b.bucket_sequence_num
,      c.org_id
UNION ALL
SELECT c.cust_account_id cust_account_id
,      b.aging_bucket_id aging_bucket_id
,      b.aging_bucket_line_id aging_bucket_line_id
,      b.bucket_sequence_num bucket_sequence_num
,      c.org_id
,      SUM(c.acctd_amount) amount
FROM   ozf_claims c
,      ozf_aging_bucket_dates b
WHERE  TRUNC(c.due_date, 'DD') <= TRUNC(b.bucket_date, 'DD')
AND    b.condition_type = 'LT'
AND    b.bucket_type = 'FUTURE'
--AND    c.status_code IN ('NEW', 'OPEN', 'PENDING_APPROVAL', 'COMPLETE', 'APPROVED')
AND    c.status_code IN ('NEW', 'OPEN', 'COMPLETE', 'REJECTED')
GROUP BY c.cust_account_id
,      b.aging_bucket_id
,      b.aging_bucket_line_id
,      b.bucket_sequence_num
,      c.org_id
UNION ALL
SELECT c.cust_account_id cust_account_id
,      b.aging_bucket_id aging_bucket_id
,      b.aging_bucket_line_id aging_bucket_line_id
,      b.bucket_sequence_num bucket_sequence_num
,      c.org_id
,      SUM(c.acctd_amount) amount
FROM   ozf_claims c
,      ozf_aging_bucket_dates b
WHERE  TRUNC(c.due_date, 'DD') >= TRUNC(b.bucket_date, 'DD')
AND    b.condition_type = 'GT'
AND    b.bucket_type = 'FUTURE'
--AND    c.status_code IN ('NEW', 'OPEN', 'PENDING_APPROVAL', 'COMPLETE', 'APPROVED')
AND    c.status_code IN ('NEW', 'OPEN', 'COMPLETE', 'REJECTED')
GROUP BY c.cust_account_id
,      b.aging_bucket_id
,      b.aging_bucket_line_id
,      b.bucket_sequence_num
,      c.org_id;

CURSOR aging_col_total_csr IS
SELECT aging_bucket_id aging_bucket_id
,      aging_bucket_line_id aging_bucket_line_id
,      bucket_sequence_num bucket_sequence_num
,      org_id
,      SUM(amount) amount
FROM   ozf_aging_summary_all
GROUP BY aging_bucket_id
,        aging_bucket_line_id
,        bucket_sequence_num
,        org_id;

l_aging_summary_rec    aging_summary_csr%ROWTYPE;
l_aging_col_total_rec  aging_col_total_csr%ROWTYPE;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   OPEN aging_summary_csr;
      LOOP
         FETCH aging_summary_csr INTO l_aging_summary_rec;
         EXIT WHEN aging_summary_csr%NOTFOUND
                OR aging_summary_csr%NOTFOUND IS NULL;
         IF l_aging_summary_rec.amount IS NOT NULL THEN
           INSERT INTO ozf_aging_summary_all (
                 cust_account_id,
                 aging_bucket_id,
                 aging_bucket_line_id,
                 bucket_sequence_num,
                 amount,
                 org_id
           ) VALUES (
                 l_aging_summary_rec.cust_account_id,
                 l_aging_summary_rec.aging_bucket_id,
                 l_aging_summary_rec.aging_bucket_line_id,
                 l_aging_summary_rec.bucket_sequence_num,
                 l_aging_summary_rec.amount,
                 l_aging_summary_rec.org_id
           );
         END IF;
      END LOOP;
   CLOSE aging_summary_csr;

   OPEN aging_col_total_csr;
      LOOP
         FETCH aging_col_total_csr INTO l_aging_col_total_rec;
         EXIT WHEN aging_col_total_csr%NOTFOUND
                OR aging_col_total_csr%NOTFOUND IS NULL;
         INSERT INTO ozf_aging_summary_all (
               cust_account_id,
               aging_bucket_id,
               aging_bucket_line_id,
               bucket_sequence_num,
               amount,
               org_id
         ) VALUES (
               -1,
               l_aging_col_total_rec.aging_bucket_id,
               l_aging_col_total_rec.aging_bucket_line_id,
               l_aging_col_total_rec.bucket_sequence_num,
               l_aging_col_total_rec.amount,
               l_aging_col_total_rec.org_id
         );
      END LOOP;
   CLOSE aging_col_total_csr;


EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_error;
END;
--------------------------------------------------------------------------------
--    API name   : Populate_Aging
--    Type       : Private
--    Pre-reqs   : None
--    Function   :
--    Parameters :
--
--    IN         : p_bucket_id        IN  NUMBER    Optional
--
--    Version    : Current version     1.0
--
--------------------------------------------------------------------------------

PROCEDURE Populate_Aging (
   ERRBUF              OUT NOCOPY VARCHAR2,
   RETCODE             OUT NOCOPY NUMBER,
   p_bucket_id         IN  NUMBER
)
IS

l_counter       NUMBER := 1;
l_msg_data      VARCHAR2(80);
l_msg_count     NUMBER;
l_return_status VARCHAR2(1);
l_seq_type      VARCHAR2(1);
l_bucket_name   VARCHAR2(20);
l_start_date            DATE;
l_end_date              DATE;
--hbandi variables for getting the Org_id
l_org_id        NUMBER;

CURSOR bucket_name_csr (p_id in number) IS
SELECT bucket_name
FROM ozf_x_aging_buckets
WHERE aging_bucket_id = p_id;

CURSOR bucket_lines_csr (p_id in number) IS
SELECT aging_bucket_id
,      aging_bucket_line_id
,      days_start
,      days_to
,      type
,      report_heading1
,      report_heading2
FROM   ozf_x_aging_bucket_lns
WHERE  aging_bucket_id = p_id
ORDER BY bucket_sequence_num;

TYPE bucket_lines_tbl IS TABLE OF bucket_lines_csr%ROWTYPE
INDEX BY BINARY_INTEGER;

l_bucket_lines_rec   bucket_lines_csr%ROWTYPE;
l_bucket_lines_tbl   bucket_lines_tbl;
l_days_start         NUMBER;
l_days_to            NUMBER;

BEGIN
   SAVEPOINT  Aging_Summary;

   IF g_debug THEN
      OZF_Utility_PVT.debug_message('== START populating aging : time stamp :: '||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.LOG, '== START populating aging : time stamp :: '||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*----------------------------------- Claim Aging Execution Report -------------------------------------*');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Starts On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------------------------------------------------------------------------------*');

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Aging Bucket id = '||p_bucket_id);

   IF p_bucket_id IS NOT NULL THEN
       OPEN bucket_name_csr(p_bucket_id);
       FETCH bucket_name_csr INTO l_bucket_name;
       CLOSE bucket_name_csr;
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Aging Buket Name: ' || l_bucket_name);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------------------------------------------------------------------------------*');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Bucket Line Name                                 Start Date    End Date     Bucket Line Type' );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '' );
   OPEN bucket_lines_csr(p_bucket_id);
      LOOP
         FETCH bucket_lines_csr INTO l_bucket_lines_tbl(l_counter);
         EXIT WHEN bucket_lines_csr%NOTFOUND
                OR bucket_lines_csr%NOTFOUND IS NULL;
         l_counter := l_counter + 1;
      END LOOP;
   CLOSE bucket_lines_csr;

   -- check if atleast one bucket exists
   IF l_bucket_lines_tbl.count = 0 THEN
      -- raise error and log message
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_AGING_NO_BUCKET');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

/*Hbandi Added this code for the Bug Fix #9273717 (+) */
   l_org_id := MO_GLOBAL.get_current_org_id;
    DELETE FROM ozf_aging_summary_all WHERE org_id = l_org_id;

 /*End of hbandi added Code (-)  */

   -- Truncate existing data
   /* TRUNCATE TABLE ozf.ozf_aging_summary_all; */
  -- DELETE FROM ozf_aging_summary_all;     --Hbandi Commented this statement and added in the above code snippet

   /* TRUNCATE table ozf.ozf_aging_bucket_dates; */
   DELETE FROM ozf_aging_bucket_dates;

   FOR i IN 1..l_bucket_lines_tbl.count LOOP
      IF i = 1 THEN
        l_seq_type := 'F';
      ELSIF i = l_bucket_lines_tbl.count THEN
        l_seq_type := 'L';
      ELSE
        l_seq_type := 'M';
      END IF;

      -- set a bound here to avoid SQL limitation: (full) year must be between -4713 and +9999, and not be 0
      IF l_bucket_lines_tbl(i).days_start > 9999 THEN
        l_days_start := 9999;
      ELSIF l_bucket_lines_tbl(i).days_start < -9999 THEN
        l_days_start := -9999;
      ELSE
        l_days_start := l_bucket_lines_tbl(i).days_start;
      END IF;

      IF l_bucket_lines_tbl(i).days_to > 9999 THEN
        l_days_to := 9999;
      ELSIF l_bucket_lines_tbl(i).days_to < -9999 THEN
        l_days_to := -9999;
      ELSE
        l_days_to := l_bucket_lines_tbl(i).days_to;
      END IF;

      IF l_bucket_lines_tbl(i).type = 'PAST' THEN
         l_start_date := sysdate - l_days_to;
         l_end_date := sysdate - l_days_start;
      ELSIF l_bucket_lines_tbl(i).type = 'CURRENT' OR
            l_bucket_lines_tbl(i).type = 'FUTURE' THEN
         l_start_date := sysdate + l_days_start;
         l_end_date := sysdate + l_days_to;
      END IF;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad(l_bucket_lines_tbl(i).report_heading1|| ' ' ||l_bucket_lines_tbl(i).report_heading2, 46, ' ')||'    '||l_start_date||'    '||l_end_date||'    '||l_bucket_lines_tbl(i).type);

      populate_aging_dates(
         p_bucket_id        => l_bucket_lines_tbl(i).aging_bucket_id,
         p_bucket_line_id   => l_bucket_lines_tbl(i).aging_bucket_line_id,
         p_bucket_sequence  => i,
         p_bucket_type      => l_bucket_lines_tbl(i).type,
         p_days_start       => l_days_start,
         p_days_to          => l_days_to,
         p_seq_type         => l_seq_type,
         x_return_status    => l_return_status
      );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Line#'||i||' -- days_start ::' || l_bucket_lines_tbl(i).days_start);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Line#'||i||' -- days_to ::' || l_bucket_lines_tbl(i).days_to);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'return status#'||i||' ::' || l_return_status);

      IF l_return_status  =  FND_API.g_ret_sts_error THEN
         -- raise error and log message
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_AGING_SUMMARY_ERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END LOOP;

   -- populate table ozf_aging_summary
   populate_aging_summary(
      x_return_status => l_return_status
   );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------------------------------------------------------------------------------*');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Total number of Bucket lines selected: ' || to_char(l_bucket_lines_tbl.count));

   IF l_return_status <> FND_API.g_ret_sts_success THEN
      -- raise error and log message
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_AGING_POPULATE_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Successful' );
   FND_FILE.PUT_LINE(FND_FILE.LOG, '== END populating aging : time stamp :: '||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------------------------------------------------------------------------------*');

   IF g_debug THEN
      OZF_Utility_PVT.debug_message('== END populating aging : time stamp :: '||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));
   END IF;
EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Aging_Summary;
      /*
      FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => l_msg_count
        ,p_data    => l_msg_data
        );
      */
      OZF_UTILITY_PVT.write_conc_log;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, 'FND_API.g_exc_error');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Failure (Error:' || FND_MSG_PUB.get(2, FND_API.g_false)||')');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------------------------------------------------------------------------------*');

      ERRBUF  := l_msg_data;
      RETCODE := 2;
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Aging_Summary;
      /*
      FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => l_msg_count
        ,p_data    => l_msg_data
        );
      */
      OZF_UTILITY_PVT.write_conc_log;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, 'FND_API.g_exc_unexpected_error');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Failure (Error:' || FND_MSG_PUB.get(2, FND_API.g_false)||')');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------------------------------------------------------------------------------*');
      ERRBUF  := l_msg_data;
      RETCODE := 2;
   WHEN OTHERS THEN
      ROLLBACK TO Aging_Summary;
      OZF_UTILITY_PVT.write_conc_log;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, 'OTHERS exception');
      ERRBUF  := substr(sqlerrm, 1, 80);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Failure (Error:' || ERRBUF||')');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------------------------------------------------------------------------------*');
      RETCODE := 2;
END Populate_Aging;

END OZF_Claim_Aging_PVT;

/
