--------------------------------------------------------
--  DDL for Package Body CN_ACC_PERIODS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ACC_PERIODS_PVT" AS
/*$Header: cnvsyprb.pls 120.7 2006/02/28 04:42:05 vensrini noship $*/

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'CN_ACC_PERIODS_PVT';

TYPE str_tbl_type IS TABLE OF gl_lookups.meaning%TYPE INDEX BY BINARY_INTEGER;

g_code_tbl str_tbl_type;
g_meaning_tbl str_tbl_type;

-- Changed cursor  fix bug#2804029
CURSOR lookup_table IS
   SELECT lookup_code, meaning
     FROM CN_lookups
     WHERE lookup_type = 'PERIOD_CLOSING_STATUS';

FUNCTION get_closing_status(p_closing_status_meaning gl_lookups.meaning%TYPE) RETURN gl_lookups.lookup_code%TYPE IS
BEGIN
--   FOR i IN 1..g_meaning_tbl.COUNT LOOP
--      IF (p_closing_status_meaning = g_meaning_tbl(i)) THEN
--	 RETURN g_code_tbl(i);
--      END IF;
--   END LOOP;
--
--   RETURN NULL;
   RETURN p_closing_status_meaning; -- vensrini
END get_closing_status;

-- Procedure to start concurrent request (in single-org context)
PROCEDURE open_period
  (errbuf        OUT NOCOPY VARCHAR2,
   retcode       OUT NOCOPY NUMBER,
   p_period_name IN VARCHAR2,
   p_freeze_flag IN VARCHAR2) IS

      l_acc_period_tbl  acc_period_tbl_type;
      l_set_of_books_id cn_repositories.set_of_books_id%TYPE;
      l_period_set_id   cn_repositories.period_set_id%TYPE;
      l_period_type_id  cn_repositories.period_type_id%TYPE;

      CURSOR repository_info IS
	 SELECT set_of_books_id,
	        period_set_id,
	        period_type_id
	   FROM cn_repositories
	  WHERE repository_id > 0
	    AND application_type = 'CN';

      -- copy of cursor in get_acc_periods proc
      -- Changed cursor  fix bug#2804029
          CURSOR periods IS
	     SELECT          cn.period_name,
	                     cn.period_year,
	                     cn.start_date,
	                     cn.end_date,
	   		     'O' closing_status_meaning,
	   		     cp.meaning processing_status,
	   		     p_freeze_flag,
	   		     cn.object_version_number
	   	       FROM  cn_period_statuses cn,
	   		     cn_lookups cp
	   		WHERE cp.lookup_type = 'PERIOD_PROCESSING_STATUS'
	   		  AND cp.lookup_code = nvl(cn.processing_status_code, 'CLEAN')
	   		  AND cn.period_set_id = l_period_set_id
		          AND cn.period_type_id = l_period_type_id
		          AND cn.period_name = p_period_name
	   	  UNION
		SELECT       gl.period_name,
		             gl.period_year,
	   		     gl.start_date,
	   		     gl.end_date,
	   		     'O' closing_status_meaning,
	   		     cp.meaning processing_status,
	   		     p_freeze_flag,
	   		     cn.object_version_number
	   	        FROM gl_period_statuses gl,
	   		     cn_period_statuses cn,
	   		     cn_lookups cp
	   		WHERE gl.set_of_books_id = l_set_of_books_id
	   		  AND gl.application_id = 283
	   		  AND gl.adjustment_period_flag = 'N'
	   		  AND gl.period_name = cn.period_name(+)
	   		  AND cp.lookup_type = 'PERIOD_PROCESSING_STATUS'
	   		  AND cp.lookup_code = nvl(cn.processing_status_code, 'CLEAN')
	   		  AND cn.period_type_id(+) = l_period_type_id
		          AND cn.period_set_id(+) = l_period_set_id
		          AND gl.period_name = p_period_name
	   		  AND not exists
	   		  (select 's' from cn_period_statuses cn1
	   		  where gl.period_name = cn1.period_name
	   		  and cn1.period_set_id = l_period_set_id
	   		  and cn1.period_type_id = l_period_type_id);

	  l_period_rec    periods%ROWTYPE;
	  l_msgs          varchar2(2000);
	  l_org_id        NUMBER;
	  l_request_id    NUMBER;
	  my_message      varchar2(2000);
	  x_return_status VARCHAR2(1);
	  x_msg_count     NUMBER;
	  x_msg_data      VARCHAR2(240);

BEGIN
   retcode := 0; -- success = 0, warning = 1, fail = 2

   -- get current working org ID
   l_org_id := mo_global.get_current_org_id;
   IF l_org_id IS NULL THEN
      -- org ID is not set... raise error
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   fnd_file.put_line(fnd_file.Log, 'start open period');

   -- wrapper for the open period procedure
   OPEN  repository_info;
   FETCH repository_info
     INTO l_set_of_books_id, l_period_set_id, l_period_type_id;
   CLOSE repository_info;

   OPEN  periods;
   FETCH periods INTO l_period_rec;
   CLOSE periods;

   l_acc_period_tbl(0) := l_period_rec;

   fnd_file.put_line(fnd_file.Log, 'open acc periods');

   update_acc_periods
     (p_api_version                => 1.0,
      p_init_msg_list              => fnd_api.g_true,
      p_org_id                     => l_org_id,
      p_acc_period_tbl             => l_acc_period_tbl,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   fnd_file.put_line(fnd_file.Log, 'start request');

   -- submit concurrent program
   start_request(l_org_id, l_request_id);

   IF l_request_id = 0 THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      rollback;
      retcode := 2;
      -- capture messages
      l_msgs := '';
      FOR l_counter IN 1..x_msg_count LOOP
	 my_message := FND_MSG_PUB.get(p_msg_index => l_counter,
				       p_encoded   => FND_API.G_FALSE);
	 fnd_file.put_line(fnd_file.Log, my_message);
	 l_msgs := l_msgs || my_message || ' ';
      end loop;
      errbuf := l_msgs;
      -- any other periods left PROCESSING should be FAILED

      update cn_period_statuses
	 set processing_status_code = 'FAILED'
       where processing_status_code = 'PROCESSING'
	 and period_name = l_period_rec.period_name;
      commit;
END open_period;

-- Procedure to start concurrent request
PROCEDURE start_request(p_org_id IN NUMBER, x_request_id OUT NOCOPY NUMBER) IS
BEGIN
   -- set org ID
   fnd_request.set_org_id(p_org_id);
   x_request_id := fnd_request.submit_request('CN', 'CN_OPEN_PERIODS',
					      NULL, NULL, NULL);
   COMMIT;
END;


-- Start of comments
--    API name        : Update_Acc_Periods
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN      NUMBER              Required
--                      p_init_msg_list       IN      VARCHAR2            Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN      VARCHAR2            Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN      NUMBER              Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_acc_period_tbl      IN      acc_period_tbl_type Required
--                        Default = null
--    IN                p_org_id              IN      NUMBER              Required
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : 1) update period_status, insert period record into cn_period_statuses if the
--                         the corresponding record does not exist in cn_period_statuses
--                      2) update cn_repositories.status if it is the first time to touch accumulation periods
--
-- End of comments

PROCEDURE Update_Acc_Periods
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_acc_period_tbl             IN      acc_period_tbl_type             ,
   p_org_id                     IN      NUMBER,
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Update_Acc_Periods';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_request_id              NUMBER;

   l_set_of_books_id       cn_repositories.set_of_books_id%TYPE;
   l_repository_id         cn_repositories.repository_id%TYPE;
   l_calendar              cn_period_sets.period_set_name%TYPE;
   l_period_set_id         cn_period_sets.period_set_id%TYPE;
   l_period_type_id        cn_period_types.period_type_id%TYPE;
   l_period_type           cn_period_types.period_type%TYPE;
   l_quarter_num           gl_period_statuses.quarter_num%TYPE;
   l_period_num            gl_period_statuses.period_num%TYPE;
   l_object_version_number cn_period_statuses.object_version_number%TYPE;
   l_closing_status        gl_period_statuses.closing_status%TYPE;
   l_closing_status_old    gl_period_statuses.closing_status%TYPE;
   l_proc_status_old       cn_period_statuses.processing_status_code%TYPE;
   l_freeze_flag_old       cn_period_statuses.freeze_flag%TYPE;
   l_pre_status            gl_period_statuses.closing_status%TYPE;
   l_next_status           gl_period_statuses.closing_status%TYPE;
   l_update_flag           VARCHAR2(1) := 'N';
   -- Added as part of bug fix bug#2804029
   l_period_status_count   NUMBER := 0;
   l_pre_gl_status_count   NUMBER := 0;
   l_next_gl_status_count   NUMBER := 0;
   l_temp_start_date	   cn_period_statuses.start_date%TYPE;
   l_org_id                cn_period_statuses.org_id%TYPE;


   CURSOR repository_info IS
      SELECT r.set_of_books_id,
	     r.repository_id,
	     ps.period_set_id,
	     ps.period_set_name,
	     pt.period_type,
	     pt.period_type_id
	FROM cn_repositories r,
	     cn_period_sets ps,
	     cn_period_types pt
       WHERE r.repository_id > 0
	 AND r.application_type = 'CN'
	 AND r.period_set_id = ps.period_set_id
	 AND r.period_type_id = pt.period_type_id
         AND r.org_id = p_org_id    -- MOAC Change
         AND r.org_id = ps.org_id   -- MOAC Change
         AND ps.org_id = pt.org_id; -- MOAC Change

   CURSOR period_info(p_period_name gl_period_statuses.period_name%TYPE) IS
      SELECT nvl(cn.org_id, p_org_id) org_id, -- MOAC Change
             gl.quarter_num,
	     gl.period_num,
	     cn.object_version_number,
	     gl.closing_status,
	     cn.freeze_flag
	FROM gl_period_statuses gl, cn_period_statuses cn
       WHERE gl.application_id = 283
	 AND gl.set_of_books_id = l_set_of_books_id
	 AND gl.period_name = p_period_name
	 AND gl.adjustment_period_flag = 'N'
	 AND gl.period_name = cn.period_name(+)
         AND cn.org_id(+) = p_org_id   -- MOAC Change
	FOR UPDATE OF gl.closing_status nowait;

   CURSOR cn_period_info(p_period_name cn_period_statuses.period_name%TYPE,
                         p_period_year cn_period_statuses.period_year%TYPE) IS
      SELECT cn.period_status, processing_status_code
      FROM cn_period_statuses cn
      WHERE  cn.period_name = p_period_name
      AND    cn.period_year = p_period_year
      AND    cn.org_id = p_org_id                     -- MOAC Change
      AND    period_type_id = l_period_type_id
      AND    period_set_id = l_period_set_id;

  -- Changed cursor  fix bug#2804029
   CURSOR pre_status_gl(p_period_year gl_period_statuses.period_year%TYPE, p_start_date DATE) IS
      SELECT count(gl.closing_status)
        FROM gl_period_statuses gl
	WHERE gl.set_of_books_id = l_set_of_books_id
	 AND gl.application_id = 283
	 AND gl.adjustment_period_flag = 'N'
	 --AND gl.period_year = p_period_year
	 AND gl.start_date < p_start_date
	ORDER BY gl.start_date;

   -- Changed cursor to refer to cn_period_status instead of gl_period_statuses
   -- as part of bug fix bug#2804029
   CURSOR pre_status(p_start_date DATE) IS
	       SELECT 'N', start_date
	         FROM gl_period_statuses gl
	 	WHERE gl.set_of_books_id = l_set_of_books_id
	 	 AND gl.application_id = 283
	 	 AND gl.adjustment_period_flag = 'N'
	 	 AND start_date < p_start_date
	 	 and not exists
		 (select 's' from cn_period_statuses cn1
		  where gl.period_name = cn1.period_name
		  and cn1.period_set_id = l_period_set_id
		  and cn1.PERIOD_TYPE_id     = l_period_type_id
		  and cn1.org_id = p_org_id)      -- MOAC Change
	  UNION
	       SELECT cn.period_status,start_date
	         FROM cn_period_statuses cn
	 	WHERE cn.period_set_id = l_period_set_id
	 	 AND  cn.period_type_id     = l_period_type_id
                 AND  cn.org_id = p_org_id  -- MOAC Change
	 	 AND  cn.start_date < p_start_date
               ORDER BY start_date DESC;

   -- Changed cursor  fix bug#2804029
   CURSOR next_status_gl(p_period_year gl_period_statuses.period_year%TYPE, p_start_date DATE) IS
      SELECT count(gl.closing_status)
        FROM gl_period_statuses gl
	WHERE gl.set_of_books_id = l_set_of_books_id
	 AND gl.application_id = 283
	 AND gl.adjustment_period_flag = 'N'
	 --AND gl.period_year = p_period_year
	 AND gl.start_date > p_start_date
       ORDER BY gl.start_date;

   -- Changed cursor to refer to cn_period_status instead of gl_period_statuses
   -- as part of bug fix bug#2804029

   CURSOR next_status(p_start_date DATE) IS
      SELECT cn.period_status
        FROM cn_period_statuses cn
	WHERE cn.period_set_id = l_period_set_id
	 AND  cn.PERIOD_TYPE_id     = l_period_type_id
         AND  cn.org_id = p_org_id   -- MOAC Change
	 AND cn.start_date > p_start_date
	ORDER BY cn.start_date;


BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
      p_api_version           ,
      l_api_name              ,
      G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   UPDATE cn_repositories
     SET status = 'A'
     WHERE repository_id > 0
     AND application_type = 'CN'
     AND org_id = p_org_id;     -- MOAC Change

   OPEN repository_info;
   FETCH repository_info INTO l_set_of_books_id, l_repository_id,l_period_set_id, l_calendar, l_period_type,l_period_type_id;
   CLOSE repository_info;

   FOR i IN p_acc_period_tbl.first..p_acc_period_tbl.last LOOP
      l_org_id := -1;
      OPEN period_info(p_acc_period_tbl(i).period_name);
      LOOP
          FETCH period_info INTO l_org_id, l_quarter_num, l_period_num, l_object_version_number, l_closing_status_old, l_freeze_flag_old;
          EXIT WHEN period_info%NOTFOUND OR l_org_id = p_org_id;
      END LOOP;
      CLOSE period_info;

--      IF (period_info%notfound) THEN
--	 CLOSE period_info;
      IF l_org_id <> p_org_id THEN
	 fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
--      CLOSE period_info;

      IF (l_object_version_number <> p_acc_period_tbl(i).object_version_number) THEN
	 fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_closing_status := get_closing_status(p_acc_period_tbl(i).closing_status_meaning);
      IF l_closing_status = 'X' THEN
      	l_closing_status := 'N';
      END IF;

      -- Added as part of bug fix bug#2804029
      OPEN cn_period_info(p_acc_period_tbl(i).period_name,p_acc_period_tbl(i).period_year );
      FETCH cn_period_info INTO l_closing_status_old,l_proc_status_old;
      IF cn_period_info%NOTFOUND THEN
      	 l_period_status_count := 0;
      	 l_closing_status_old := 'N';
	 l_proc_status_old    := 'CLEAN';
      ELSE
      	 l_period_status_count := 1;
      END IF;
      CLOSE cn_period_info;
      -- End add as part of bug fix bug#2804029

      IF (l_closing_status <> l_closing_status_old OR
	  nvl(l_freeze_flag_old, 'N') <> nvl(p_acc_period_tbl(i).freeze_flag, 'N' ) OR
	  l_proc_status_old = 'FAILED') THEN
	 l_update_flag := 'Y';

	 -- update the existing gl_period_statuses record
	 IF (i > p_acc_period_tbl.first) THEN
	    l_pre_status := get_closing_status(p_acc_period_tbl(i-1).closing_status_meaning);
	  ELSE
	    OPEN pre_status(p_acc_period_tbl(i).start_date);
	    FETCH pre_status INTO l_pre_status,l_temp_start_date;
	    IF (pre_status%notfound) THEN
	       -- changes for bug#2804029
	       OPEN pre_status_gl(p_acc_period_tbl(i).period_year, p_acc_period_tbl(i).start_date);
	       FETCH pre_status_gl INTO l_pre_gl_status_count;
	       CLOSE pre_status_gl;
	       IF l_pre_gl_status_count = 0 THEN
	       		l_pre_status := 'B';
               ELSE
               		l_pre_status := 'N';
	       END IF;
	    END IF;
	    CLOSE pre_status;
	 END IF;

       	IF l_pre_status = 'X' THEN
	       	l_pre_status := 'N';
         END IF;

	 IF (i < p_acc_period_tbl.last) THEN
	    l_next_status := get_closing_status(p_acc_period_tbl(i+1).closing_status_meaning);
	  ELSE
            OPEN next_status( p_acc_period_tbl(i).start_date);
	    FETCH next_status INTO l_next_status;
	    IF (next_status%notfound) THEN
	       -- changes for bug#2804029
	       OPEN next_status_gl(p_acc_period_tbl(i).period_year, p_acc_period_tbl(i).start_date);
	       FETCH next_status_gl INTO l_pre_gl_status_count;
	       CLOSE next_status_gl;
	       IF l_next_gl_status_count = 0 THEN
	        l_next_status := 'L';
	       ELSE
	       	l_next_status := 'N';
	       END IF;
	    END IF;
	    CLOSE next_status;

	 END IF;

	 IF l_next_status = 'X' THEN
	    l_next_status := 'N';
         END IF;

	 /* commented out for bug 5035044
	 IF (l_quarter_num NOT IN (1, 2, 3, 4)) THEN
	    fnd_message.set_name('CN', 'CNSYPR_QUARTER_NUMBER');
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_error;
	 END IF;
	 */

	 IF (l_closing_status = 'O' AND l_closing_status_old <> 'O' ) THEN
	    IF (l_closing_status_old = 'P') THEN
	       fnd_message.set_name('CN', 'CNSYPR_OPEN_PERIOD');
	       fnd_msg_pub.add;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    -- can not open a period whose previous period is Never Opened
	    IF (l_pre_status = 'N') THEN
	       fnd_message.set_name('CN', 'CNSYPR_OPEN_PRE_NEVER');
	       fnd_msg_pub.add;
	       RAISE fnd_api.g_exc_error;
	     -- can not open a period whose previous period is Future Enterable
	     elsif (l_pre_status = 'F') then
	       fnd_message.set_name('CN', 'CNSYPR_OPEN_PRE_FUTURE');
	       fnd_msg_pub.add;
	       raise fnd_api.g_exc_error;

	     -- can not open a period whose next period is Closed or Permanently Closed
	     elsif (l_next_status IN ('P', 'C')) then
	       fnd_message.set_name('CN', 'CNSYPR_OPEN_NEXT_CLOSE');
	       fnd_msg_pub.add;
	       raise fnd_api.g_exc_error;
	    end if;
	 END IF;

	 IF ((l_closing_status = 'C' AND l_closing_status_old <> 'C') OR (l_closing_status = 'P' AND l_closing_status_old <> 'P')) THEN
	    --IF ((l_closing_status = 'C' AND l_closing_status_old <> 'O') OR (l_closing_status = 'P' AND l_closing_status_old NOT IN ('O', 'C'))) THEN
	    --   fnd_message.set_name('CN', 'CN_CLOSE_PERIOD');
	    --   fnd_msg_pub.add;
	    --   RAISE fnd_api.g_exc_error;
	    --END IF;

	    -- can not close/permanently close a period whose previous period is not closed
	    -- Note: when a period is open, it is impossible for its previous period to be Never Opened or Future Entry
	    if (l_pre_status = 'O') then
	       fnd_message.set_name('CN', 'CNSYPR_CLOSE_PRE_OPEN');
	       fnd_msg_pub.add;
	       raise fnd_api.g_exc_error;
	     END IF;
	 END IF;

	 IF (l_closing_status = 'F' AND l_closing_status_old <> 'F') THEN
	    IF (l_closing_status_old <> 'N') THEN
	       fnd_message.set_name('CN', 'CNSYPR_FUTURE_ENTERABLE');
	       fnd_msg_pub.add;
	       RAISE fnd_api.g_exc_error;
	    END IF;

	    -- can not set a period to F whose previous period is Never Opened
	    if (l_pre_status = 'N') then
	       fnd_message.set_name('CN', 'CNSYPR_FUTURE_PRE_NEVER');
	       fnd_msg_pub.add;
	       raise fnd_api.g_exc_error;
	    END IF;
	 END IF;

	 cn_periods_api.update_gl_status(p_org_id,   -- MOAC Change
                                         p_acc_period_tbl(i).period_name,
					 l_closing_status,
					 'Y',
					 283,
					 l_set_of_books_id,
					 p_acc_period_tbl(i).freeze_flag,
					 sysdate,
					 fnd_global.login_id,
					 fnd_global.user_id);

	 -- create a matching CN_PERIOD_STATUSES record if necessary
	 cn_periods_api.check_cn_period_record
	   (x_org_id              => p_org_id,                   -- MOAC Change
            x_period_name         => p_acc_period_tbl(i).period_name,
	    x_closing_status      => l_closing_status,
	    x_period_type         => l_period_type,
	    x_period_year         => p_acc_period_tbl(i).period_year,
	    x_quarter_num         => l_quarter_num,
	    x_period_num          => l_period_num,
	    x_period_set_name     => l_calendar,
	    x_start_date          => p_acc_period_tbl(i).start_date,
	    x_end_date            => p_acc_period_tbl(i).end_date,
	    x_freeze_flag         => p_acc_period_tbl(i).freeze_flag,
	    x_repository_id       => l_repository_id);

      END IF;
   END LOOP;

   -- bug 1979768 : move all the srp table insert into a concurrent program
   -- commit here to force the update on cn_period_statuses.
   --commit;

    --this section is added for intimating the user that updates were not saved
    --because the information was identical to what exists in the db.
    --bug # 2471028

   IF (l_update_flag = 'N') THEN
   	fnd_message.set_name('CN', 'CN_NO_CHANGES');
   	fnd_msg_pub.add;
   END IF;

   -- Call concurrent program
   -- commented since it has moved to start_request procedure
--   IF (l_update_flag = 'Y') THEN
--      l_request_id := fnd_request.submit_request
--	(
--	 application 		=> 'CN'
--	 ,program     		=> 'CN_OPEN_PERIODS'
--	 ,description 		=> NULL
--	 ,start_time  		=> NULL
--	 ,sub_request 		=> NULL);
--
--      IF l_request_id = 0 THEN
--	 RAISE FND_API.g_exc_unexpected_error;
--      END IF;
--   END IF;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.add_exc_msg
	   (G_PKG_NAME          ,
	    l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
	(p_count                 =>      x_msg_count             ,
	 p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
END update_acc_periods;

-- populate the accumulation periods screen
PROCEDURE get_acc_periods
  (p_year                         IN      NUMBER,
   x_system_status                OUT NOCOPY     cn_lookups.meaning%TYPE,
   x_calendar                     OUT NOCOPY     cn_period_sets.period_set_name%TYPE,
   x_period_type                  OUT NOCOPY     cn_period_types.period_type%TYPE,
   x_acc_period_tbl               OUT NOCOPY     acc_period_tbl_type)
IS
   l_set_of_books_id cn_repositories.set_of_books_id%TYPE;
   l_period_set_id   cn_repositories.period_set_id%TYPE;
   l_period_type_id  cn_repositories.period_type_id%TYPE;
   l_current_year    gl_period_statuses.period_year%TYPE;

   CURSOR current_year IS
      SELECT period_year
	FROM gl_period_statuses
	WHERE trunc(sysdate) BETWEEN start_date AND end_date
	AND application_id = 283
	AND adjustment_period_flag = 'N'
	AND set_of_books_id = (SELECT set_of_books_id
			       FROM cn_repositories
			       WHERE repository_id > 0
			       AND application_type = 'CN')
	AND ROWNUM = 1;

   CURSOR first_year IS
      SELECT max(period_year)
	FROM gl_period_statuses
	WHERE application_id = 283
	AND adjustment_period_flag = 'N'
	AND set_of_books_id = (SELECT set_of_books_id
			       FROM cn_repositories
			       WHERE repository_id > 0
			       AND application_type = 'CN')
	;

   CURSOR repository_info IS
      SELECT status,
	     set_of_books_id,
	     period_set_id,
	     period_type_id
	FROM cn_repositories
       WHERE repository_id > 0
	 AND application_type = 'CN';

   CURSOR calendar IS
      SELECT period_set_name
	FROM cn_period_sets
	WHERE period_set_id = l_period_set_id;

   CURSOR period_type IS
      SELECT period_type
	FROM cn_period_types
	WHERE period_type_id = l_period_type_id;

   -- Changed cursor  fix bug#2804029
   CURSOR periods IS
        SELECT   cn.period_name,
		     cn.period_year,
		     cn.start_date,
		     cn.end_date,
		     gp.meaning closing_status_meaning,
		     cp.meaning processing_status,
		     cn.freeze_flag,
		     cn.object_version_number
	       FROM  cn_period_statuses cn,
		     cn_lookups gp,
		     cn_lookups cp
		WHERE
		   gp.lookup_type = 'PERIOD_CLOSING_STATUS'
		  AND gp.lookup_code = cn.PERIOD_STATUS
		  AND cp.lookup_type = 'PERIOD_PROCESSING_STATUS'
		  AND cp.lookup_code = nvl(cn.processing_status_code, 'CLEAN')
		  AND cn.period_year = nvl(p_year, l_current_year)
		  AND cn.period_set_id = l_period_set_id
		  AND cn.period_type_id	 = l_period_type_id
	  UNION
	     SELECT gl.period_name,
		     gl.period_year,
		     gl.start_date,
		     gl.end_date,
		     gp.meaning closing_status_meaning,
		     cp.meaning processing_status,
		     cn.freeze_flag,
		     cn.object_version_number
	        FROM gl_period_statuses gl,
		     cn_period_statuses cn,
		     cn_lookups gp,
		     cn_lookups cp
		WHERE gl.set_of_books_id = l_set_of_books_id
		  AND gl.application_id = 283
		  AND gl.adjustment_period_flag = 'N'
		  AND gl.period_name = cn.period_name(+)
		  AND gp.lookup_type = 'PERIOD_CLOSING_STATUS'
		  AND gp.lookup_code = DECODE(gl.CLOSING_STATUS,'N','N','X')
		  AND cp.lookup_type = 'PERIOD_PROCESSING_STATUS'
		  AND cp.lookup_code = nvl(cn.processing_status_code, 'CLEAN')
		  AND gl.period_year = nvl(p_year, l_current_year)
		  AND cn.period_type_id(+)	 = l_period_type_id
		  AND cn.period_set_id (+) = l_period_set_id
		 and not exists
		  (select 's' from cn_period_statuses cn1
		  where gl.period_name = cn1.period_name
		  and cn1.period_set_id = l_period_set_id
		  and cn1.period_type_id	 = l_period_type_id)
	  order by 2,3;





BEGIN
   OPEN repository_info;
   FETCH repository_info INTO x_system_status, l_set_of_books_id, l_period_set_id, l_period_type_id;
   CLOSE repository_info;

   OPEN calendar;
   FETCH calendar INTO x_calendar;
   CLOSE calendar;

   OPEN period_type;
   FETCH period_type INTO x_period_type;
   CLOSE period_type;

   x_system_status := cn_api.get_lkup_meaning(x_system_status, 'REPOSITORY_STATUS');

   IF (p_year IS NULL) THEN
      OPEN current_year;
      FETCH current_year INTO l_current_year;
      CLOSE current_year;
      IF l_current_year is null then
	 OPEN first_year;
	 FETCH first_year INTO l_current_year;
	 CLOSE first_year;
      END IF;
    ELSE
      l_current_year := p_year;
   END IF;

   FOR period IN periods LOOP
      x_acc_period_tbl(x_acc_period_tbl.COUNT + 1) := period;
      IF (x_acc_period_tbl(x_acc_period_tbl.COUNT).freeze_flag IS NULL) THEN
	 x_acc_period_tbl(x_acc_period_tbl.COUNT).freeze_flag := 'N';
      END IF;
   END LOOP;
END get_acc_periods;

BEGIN
   FOR lkup IN lookup_table LOOP
      g_code_tbl(g_code_tbl.COUNT + 1) := lkup.lookup_code;
      g_meaning_tbl(g_meaning_tbl.COUNT + 1) := lkup.meaning;
   END LOOP;

END CN_ACC_PERIODS_PVT;

/
