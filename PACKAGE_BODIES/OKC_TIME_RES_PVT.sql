--------------------------------------------------------
--  DDL for Package Body OKC_TIME_RES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TIME_RES_PVT" AS
/* $Header: OKCCRESB.pls 120.2 2006/02/24 15:11:51 smallya noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE Get_K_Effectivity(
    p_chr_id IN NUMBER,
    p_cle_id IN NUMBER,
    x_start_date OUT NOCOPY DATE,
    x_end_date OUT NOCOPY DATE,
    x_return_status OUT NOCOPY VARCHAR2) IS

    CURSOR chr_csr(p_chr_id IN NUMBER) is
     select start_date, end_date
      from okc_k_headers_b
      where id = p_chr_id;

    CURSOR cle_csr(p_cle_id IN NUMBER) is
     select start_date, end_date
      from okc_k_lines_b
      where id = p_cle_id;

    l_row_not_found                BOOLEAN := TRUE;
    l_chr_rec                      chr_csr%ROWTYPE;
    l_cle_rec                      cle_csr%ROWTYPE;
    l_token_value                  varchar2(10) := OKC_API.G_MISS_CHAR;
  BEGIN

  /* Get the effectivity of the contract header or lines */

    x_start_date := NULL;
    x_end_date := NULL;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cle_id is NOT NULL and
	  p_cle_id <> OKC_API.G_MISS_NUM Then
	  l_token_value := 'CLE_ID';
       OPEN cle_csr(p_cle_id);
       FETCH cle_csr into l_cle_rec;
       l_row_not_found := cle_csr%NOTFOUND;
       CLOSE cle_csr;
       IF (l_row_not_found) THEN
         OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLE_ID');
         x_return_status := OKC_API.G_RET_STS_ERROR;
	 return;
       ELSE
         x_start_date := l_cle_rec.start_date;
         x_end_date   := l_cle_rec.end_date;
       END IF;
    ELSIF p_chr_id is NOT NULL and
	  p_chr_id <> OKC_API.G_MISS_NUM THEN
       l_token_value := 'CHR_ID';
       OPEN chr_csr(p_chr_id);
       FETCH chr_csr into l_chr_rec;
       l_row_not_found := chr_csr%NOTFOUND;
       CLOSE chr_csr;
       IF (l_row_not_found) THEN
         OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_ID');
         x_return_status := OKC_API.G_RET_STS_ERROR;
	    return;
       ELSE
         x_start_date := l_chr_rec.start_date;
         x_end_date := l_chr_rec.end_date;
       END IF;
     END IF;
-- The following block is added for Bug#2386569 regarding initialization for perpetual contracts
     IF x_start_date IS NULL Then
        x_start_date := to_date('01010001','ddmmyyyy');
     end if;
     IF x_end_date IS NULL Then
        x_end_date := to_date('31124000','ddmmyyyy');
     end if;

    EXCEPTION
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => l_token_value,
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   END Get_K_Effectivity;

  PROCEDURE Get_Timezone(
    p_tze_id IN NUMBER,
    x_tze_name OUT NOCOPY VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2) IS
    CURSOR okc_timezone_csr  is
	 SELECT global_timezone_name
	 from okx_timezones_v
	 where timezone_id = p_tze_id;
    l_okc_timezone_rec okc_timezone_csr%ROWTYPE;
    item_not_found_error          EXCEPTION;
    l_row_notfound                 BOOLEAN := TRUE;
   BEGIN

  -- Get the timezone name from the timezone id which is also required for the JTF_TASKS API

	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	OPEN okc_timezone_csr;
     FETCH okc_timezone_csr INTO l_okc_timezone_rec;
      l_row_notfound := okc_timezone_csr%NOTFOUND;
     CLOSE okc_timezone_csr;
     IF (l_row_notfound) THEN
       OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TZE_ID');
       RAISE item_not_found_error;
     END IF;
	x_tze_name := l_okc_timezone_rec.global_timezone_name;
    EXCEPTION
      WHEN item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'TZE_ID',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    End Get_Timezone;

  PROCEDURE Create_RTV_N_Tasks(
    x_return_status     OUT NOCOPY VARCHAR2,
    p_api_version	    IN NUMBER,
    p_init_msg_list     IN VARCHAR2 ,
    p_tve_id            IN NUMBER,
    p_date              IN DATE,
    p_cutoff_date       IN DATE ,
    p_coe_id            IN NUMBER ,
    p_tze_id            IN NUMBER,
    p_tze_name          VARCHAR2) IS
    l_api_version            CONSTANT NUMBER := 1;
    l_api_name               CONSTANT VARCHAR2(30) := 'Create_RTV_N_Tasks';
    l_msg_count              NUMBER;
    x_msg_count              NUMBER;
    x_task_id                NUMBER;
    l_msg_data               VARCHAR2(2000);
    x_msg_data               VARCHAR2(2000);
    l_rtvv_rec               OKC_TIME_PUB.rtvv_rec_type;
    x_rtvv_rec               OKC_TIME_PUB.rtvv_rec_type;
  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
									 p_init_msg_list,
									 '_COMPLEX',
									 x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	  raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

  -- Cutoff Date is the date which will actually be the start date for the time resolving window

	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	if p_cutoff_date is NOT NULL Then
	  if p_date < p_cutoff_date then
	    return;
       end if;
     end if;
    l_rtvv_rec.tve_id := p_tve_id;
    l_rtvv_rec.datetime := p_date;
    l_rtvv_rec.coe_id := p_coe_id;
    -- Creating Resolved timevalues
    OKC_TIME_PUB.CREATE_RESOLVED_TIMEVALUES(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rtvv_rec,
      x_rtvv_rec );

	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
	   raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
	   raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

/*    if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	  return;
    end if;*/

    -- Creating Tasks
    OKC_TASK_PUB.CREATE_TASK(
       p_api_version,
       p_init_msg_list,
	  'F',
	  x_rtvv_rec.id,
	  p_tze_id,
	  p_tze_name,
	  p_tve_id,
	  p_date,
       x_return_status,
       x_msg_count,
       x_msg_data,
	  x_task_id);

     IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
	   raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
	   raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

	  OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);

     EXCEPTION
		WHEN OKC_API.G_EXCEPTION_ERROR THEN
		 x_return_status := OKC_API.HANDLE_EXCEPTIONS
		 (l_api_name,
		  G_PKG_NAME,
		  'OKC_API.G_RET_STS_ERROR',
		  x_msg_count,
		  x_msg_data,
		  '_COMPLEX');
		WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		 x_return_status := OKC_API.HANDLE_EXCEPTIONS
		 (l_api_name,
		  G_PKG_NAME,
		  'OKC_API.G_RET_STS_UNEXP_ERROR',
		  x_msg_count,
		  x_msg_data,
		  '_COMPLEX');
		WHEN OTHERS THEN
		 x_return_status := OKC_API.HANDLE_EXCEPTIONS
		 (l_api_name,
		  G_PKG_NAME,
		  'OTHERS',
		  x_msg_count,
		  x_msg_data,
		  '_COMPLEX');

  END Create_RTV_N_Tasks;

  PROCEDURE Res_day_of_week(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    p_tve_id  IN NUMBER,
    p_tze_id  IN NUMBER,
    p_tze_name IN                     VARCHAR2,
    p_start_date IN DATE,
    p_end_date  IN DATE,
    p_cutoff_date IN DATE ,
    p_nth IN NUMBER,
    p_daynum_of_week IN NUMBER,
    p_hour IN NUMBER,
    p_minute IN NUMBER,
    p_second IN NUMBER) IS
    l_daynum_of_week              number := OKC_API.G_MISS_NUM;
    l_daynum_offset               number := OKC_API.G_MISS_NUM;
    l_date                        date := OKC_API.G_MISS_DATE;
    l_start_day_of_month          date := OKC_API.G_MISS_DATE;
    l_nth                         NUMBER := p_nth;
    x_msg_count              NUMBER;
    x_task_id              NUMBER;
    x_msg_data               VARCHAR2(2000);
    BEGIN

    /* resolving day of the week to an actual date
	  e.g. 5th Monday between 1st Jan 2000 and 30th june 2000 will be 31st Jan 2000 and 29 th May 2000
    */

      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
	 if l_nth = 0 or l_nth is NULL then
	   l_daynum_of_week               := to_char(p_start_date,'D');
	   l_daynum_offset := p_daynum_of_week - l_daynum_of_week ;
	   if l_daynum_offset < 0 then
	      l_daynum_offset := 7 + l_daynum_offset;
	   end if;
	   l_date := to_date(to_char(p_start_date + l_daynum_offset,'mmddyyyy') ||
	 	   lpad(p_hour,2,'0') ||
	        lpad(p_minute,2,'0') ||
	        lpad(p_second,2,'0'), 'mmddyyyyhh24miss');
	   if l_date > p_end_date then
          x_return_status                := OKC_API.G_RET_STS_SUCCESS;
		return;
	   end if;
	   while (l_date <= p_end_date) loop
          Create_RTV_N_Tasks(
            x_return_status,
            p_api_version,
            p_init_msg_list,
            p_tve_id,
            l_date,
		  p_cutoff_date,
		  NULL,
            p_tze_id,
            p_tze_name);
		if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		  exit;
          end if;
	     l_date := l_date + 7;
	   end loop;
      else

	 /* nth is the frequency i.e. 99 means last e.g. nth=99, day_of_week=1 will mean Last Sunday */

	   if l_nth = 99 then
	      l_nth := 5;
        end if;
	   l_start_day_of_month := to_date(to_char(p_start_date,'mmyyyy'),'mmyyyy');
	   while l_date <= p_end_date loop
	     l_daynum_of_week               := to_char(l_start_day_of_month,'D');
	     l_daynum_offset := p_daynum_of_week - l_daynum_of_week ;
	     if l_daynum_offset < 0 then
	        l_daynum_offset := 7 + l_daynum_offset;
	     end if;
	     l_daynum_offset := l_daynum_offset + (l_nth - 1) * 7;
	     l_date := to_date(to_char(l_start_day_of_month + l_daynum_offset,'mmddyyyy') ||
	 	   lpad(p_hour,2,'0') ||
	        lpad(p_minute,2,'0') ||
	        lpad(p_second,2,'0'), 'mmddyyyyhh24miss');
          while (to_char(l_date,'MM') <> to_char(l_start_day_of_month,'MM')) loop
		  l_date := l_date - 7;
          end loop;
	     if l_date >= p_start_date  and l_date <= p_end_date then
             Create_RTV_N_Tasks(
               x_return_status,
               p_api_version,
               p_init_msg_list,
               p_tve_id,
               l_date,
			p_cutoff_date,
               NULL,
               p_tze_id,
               p_tze_name);
		   if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		    exit;
		   end if;
          end if;
		l_start_day_of_month := add_months(l_start_day_of_month,1);
	  end loop;
    end if;
  END Res_day_of_week;

  PROCEDURE Res_Time_Events (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    p_cnh_id                       IN NUMBER,
    p_coe_id                       IN NUMBER,
    p_date                         IN date) IS
    item_not_found_error          EXCEPTION;
    CURSOR okc_tgn_csr (p_cnh_id IN NUMBER)
    IS
    SELECT id, tze_id
     FROM OKC_TIMEVALUES tgn
     WHERE cnh_id = p_cnh_id
	 AND tve_type = 'TGN';

    CURSOR okc_tal_csr (p_id                 IN NUMBER)
    IS
      SELECT id, tve_type, duration, operator, before_after, datetime, tve_id_offset, uom_code, tze_id
      FROM Okc_Timevalues
      connect by tve_id_offset = prior id
      start with tve_id_offset = p_id;

    l_okc_tal_rec                 okc_tal_csr%ROWTYPE;
    l_okc_tgn_rec                 okc_tgn_csr%ROWTYPE;
    l_date                        date;
    l_end_date                    date := NULL; -- bug#2337567 -- default value
    l_tze_name                    OKX_TIMEZONES_V.global_timezone_name%TYPE;
    x_task_id                     NUMBER;
    l_tze_id                 NUMBER;
    l_tve_id                 NUMBER;
    x_msg_count              NUMBER;
    x_msg_data               VARCHAR2(2000);
    l_found                  BOOLEAN := FALSE;
    l_cutoff_date            DATE := NULL;
    BEGIN

    /*
	 Resolve timevalues related to an event e.g 10 days after Contract Signing. Will be triggered only when the
	 event occurs
    */

      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
	 l_date := NULL;
      OPEN okc_tgn_csr(p_cnh_id);
	 LOOP
        FETCH okc_tgn_csr INTO l_okc_tgn_rec;
	   EXIT WHEN okc_tgn_csr%NOTFOUND;
           l_found      := FALSE;   -- bug#2337567  -- moved up from bottom
           l_end_date   := NULL;    -- bug#2337567  -- the initialization was lost
	        l_date       := p_date;
        FOR l_okc_tal_rec in okc_tal_csr(l_okc_tgn_rec.id)
	   LOOP
		 l_found := TRUE;
		 if l_okc_tal_rec.before_after = 'B' then
		    l_okc_tal_rec.duration := -1 * l_okc_tal_rec.duration;
		 end if;
           l_end_date := OKC_TIME_UTIL_PUB.GET_ENDDATE(
						l_date,
                              l_okc_tal_rec.uom_code,
					     l_okc_tal_rec.duration);
           if l_end_date is NULL Then
             OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'END_DATE');
             x_return_status := OKC_API.G_RET_STS_ERROR;
		   exit;
           end if;
		 if ((l_end_date - l_date) >= 1) then
		   l_date := l_end_date + 1;
		 else
		   l_date := l_end_date + (86399/86400);
		 end if;
	      l_tve_id := l_okc_tal_rec.id;
		 l_tze_id := l_okc_tal_rec.tze_id;
	  END LOOP;
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	    exit;
       END IF;
       IF l_end_date is NULL THEN
	    if l_found  THEN
		 goto next_record;
	    else
	      l_end_date := p_date;
	      l_tve_id := l_okc_tgn_rec.id;
	      l_tze_id := l_okc_tgn_rec.tze_id;
         END IF;
       END IF;
	  if l_tze_id is NOT NULL and
	     l_tze_id <> OKC_API.G_MISS_NUM then
          Get_Timezone(l_tze_id, l_tze_name, x_return_status);
	     if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	       exit;
	     end if;
	  else
	    l_tze_name := NULL;
	  end if;
       Create_RTV_N_Tasks(
         x_return_status,
         p_api_version,
         p_init_msg_list,
         l_tve_id,
         l_end_date,
	    l_cutoff_date,
	    p_coe_id,
         l_tze_id,
         l_tze_name);
	  if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	    exit;
	  end if;
	 << next_record>>
            null;    -- bug#2337567 -- see initialization in head of the loop
	END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'TVE_ID',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END  Res_Time_Events ;

  PROCEDURE Res_TPG_Delimited (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    p_tve_id                       IN NUMBER,
    p_tze_id                       IN NUMBER,
    p_tze_name                     VARCHAR2,
    p_month                        IN NUMBER,
    p_day                          IN NUMBER,
    p_nth                          IN NUMBER,
    p_day_of_week                  IN VARCHAR2,
    p_hour                         IN NUMBER,
    p_minute                       IN NUMBER,
    p_second                       IN NUMBER,
    p_start_date                   IN date,
    p_end_date                     IN date,
    p_cutoff_date                 IN date) IS
    l_month                       NUMBER := OKC_API.G_MISS_NUM;
    l_start_date1                  date := OKC_API.G_MISS_DATE;
    l_end_date1                    date := OKC_API.G_MISS_DATE;
    l_start_date                  date := OKC_API.G_MISS_DATE;
    l_end_date                    date := OKC_API.G_MISS_DATE;
    l_date                        date := OKC_API.G_MISS_DATE;
    l_daynum_of_week              NUMBER;
    x_msg_count              NUMBER;
    x_msg_data               VARCHAR2(2000);
    x_task_id                     NUMBER;
    BEGIN

    /*
	 Resolve all generic dates e.g. Last day of every month or, 15th of every month etc.
	 Nth is the frequency i.e. 99 means last e.g. nth=99, day_of_week=1 will mean Last Sunday.
	 Also p_day=99 means the last day of the month
    */

      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
	 /* Find the start and end dates if not passed and store them in l_start_date1 and l_end_date1 */
	 if (p_start_date is null or p_start_date = OKC_API.G_MISS_DATE) then
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'START_DATE');
        x_return_status := OKC_API.G_RET_STS_ERROR;
	   return;
	 elsif (p_end_date is null or p_end_date = OKC_API.G_MISS_DATE) then
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'END_DATE');
        x_return_status := OKC_API.G_RET_STS_ERROR;
	   return;
	 else
	   if p_start_date > p_end_date then
          x_return_status := OKC_API.G_RET_STS_ERROR;
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'START_DATE');
	     return;
	   end if;
	   l_start_date1 := p_start_date;
	   l_end_date1 := p_end_date;
	 end if;
	 if (p_day_of_week is NOT NULL and p_day_of_week <> OKC_API.G_MISS_CHAR) then
	   if p_day_of_week = 'SUN' then
		l_daynum_of_week := 1;
	   elsif p_day_of_week = 'MON' then
		l_daynum_of_week := 2;
	   elsif p_day_of_week = 'TUE' then
		l_daynum_of_week := 3;
	   elsif p_day_of_week = 'WED' then
		l_daynum_of_week := 4;
	   elsif p_day_of_week = 'THU' then
		l_daynum_of_week := 5;
	   elsif p_day_of_week = 'FRI' then
		l_daynum_of_week := 6;
	   elsif p_day_of_week = 'SAT' then
		l_daynum_of_week := 7;
	   end if;
	 end if;
	 If p_month is not null then
	   l_month := to_char(l_start_date1,'MM');
	   if l_month = p_month then
		l_start_date := l_start_date1;
	   elsif l_month < p_month then
		l_start_date := to_date('01'||lpad(p_month,2,0)||to_char(l_start_date1,'YYYY'),'ddmmyyyy');
	   elsif l_month > p_month then
		l_start_date := to_date('01'||lpad(p_month,2,0)||to_char(to_number(to_char(l_start_date1,'YYYY')) +1),'ddmmyyyy');
        end if;
	   l_end_date := last_day(l_start_date);
	   if l_end_date1 < l_end_date then
		l_end_date := l_end_date1;
	   end if;
	   if l_start_date > l_end_date then
	   /* Will never be resolved */
	     return;
	   end if;
	   while (l_start_date <= l_end_date1) loop
	     If p_day_of_week is not null then
            Res_day_of_week(x_return_status,
                            p_api_version,
                            p_init_msg_list,
                            p_tve_id,
                            p_tze_id,
					   p_tze_name,
		  			   l_start_date,
		  			   l_end_date,
					   p_cutoff_date,
		  			   p_nth,
		  			   l_daynum_of_week,
		  			   p_hour,
		  			   p_minute,
		  			   p_second);
          elsif p_day is not null and
	  	    p_day <> 99 then
	       l_date := to_date(lpad(p_day,2,'0') ||
		  			   to_char(l_start_date,'mmyyyy') ||
		  			   lpad(p_hour,2,'0') ||
		  			   lpad(p_minute,2,'0') ||
		  			   lpad(p_second,2,'0'),'ddmmyyyyhh24miss');
	       if l_date >= l_start_date then
              Create_RTV_N_Tasks(
                x_return_status,
                p_api_version,
                p_init_msg_list,
                p_tve_id,
                l_date,
			 p_cutoff_date,
	           NULL,
                p_tze_id,
                p_tze_name);
		    if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		      exit;
		    end if;
		  end if;
          elsif p_day = 99 then
	       l_date := last_day(to_date( to_char(l_start_date,'mmyyyy') ||
					   lpad(p_hour,2,'0') ||
					   lpad(p_minute,2,'0') ||
					   lpad(p_second,2,'0'),'mmyyyyhh24miss'));
            Create_RTV_N_Tasks(
              x_return_status,
              p_api_version,
              p_init_msg_list,
              p_tve_id,
              l_date,
		    p_cutoff_date,
	         NULL,
              p_tze_id,
              p_tze_name);
		  if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		    exit;
		  end if;
	     end if;
	     l_start_date := to_date('01'||lpad(p_month,2,0)||to_char(to_number(to_char(l_start_date,'yyyy'))+1),'ddmmyyyy');
	     l_end_date := last_day(l_start_date);
	     if l_end_date1 < l_end_date then
		  l_end_date := l_end_date1;
	     end if;
	   end loop;
      end if;
    If p_day_of_week is not null and
	  p_month is null then
      Res_day_of_week(x_return_status,
                      p_api_version,
                      p_init_msg_list,
                      p_tve_id,
                      p_tze_id,
                      p_tze_name,
		  		  l_start_date1,
		  		  l_end_date1,
				  p_cutoff_date,
				  p_nth,
				  l_daynum_of_week,
				  p_hour,
				  p_minute,
				  p_second);
    elsif p_day is not null and
          p_day <> 99 and
	     p_month is null then
		l_start_date := l_start_date1;
	     l_date := to_date(lpad(p_day,2,'0') ||
				   to_char(l_start_date,'mmyyyy') ||
				   lpad(p_hour,2,'0') ||
				   lpad(p_minute,2,'0') ||
				   lpad(p_second,2,'0'),'ddmmyyyyhh24miss');
	 while (l_date <= l_end_date1) loop
	   if l_date >= l_start_date1 then
          Create_RTV_N_Tasks(
            x_return_status,
            p_api_version,
            p_init_msg_list,
            p_tve_id,
            l_date,
		  p_cutoff_date,
	       NULL,
            p_tze_id,
            p_tze_name);
		if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		  exit;
		end if;
	    end if;
	   l_date := add_months(l_date,1);
	 end loop;
    elsif p_day = 99 and
	  p_month is null then
	  l_start_date := l_start_date1;
	 l_date := last_day(to_date( to_char(l_start_date,'mmyyyy') ||
				   lpad(p_hour,2,'0') ||
				   lpad(p_minute,2,'0') ||
				   lpad(p_second,2,'0'),'mmyyyyhh24miss'));
	 while (l_date <= l_end_date1) loop
        Create_RTV_N_Tasks(
          x_return_status,
          p_api_version,
          p_init_msg_list,
          p_tve_id,
          l_date,
		p_cutoff_date,
	     NULL,
          p_tze_id,
          p_tze_name);
	   if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	    exit;
	   end if;
	   l_date := add_months(l_date,1);
	 end loop;
    elsif (p_day is null and  /* Every day */
		 p_month is null and
		 p_day_of_week is null) then
		l_start_date := l_start_date1;
	 l_date := to_date( to_char(l_start_date,'yyyymmdd') ||
				   lpad(p_hour,2,'0') ||
				   lpad(p_minute,2,'0') ||
				   lpad(p_second,2,'0'),'yyyymmddhh24miss');
	 while (l_date <= l_end_date1) loop
        Create_RTV_N_Tasks(
          x_return_status,
          p_api_version,
          p_init_msg_list,
          p_tve_id,
          l_date,
		p_cutoff_date,
	     NULL,
          p_tze_id,
          p_tze_name);
	   if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	    exit;
	   end if;
	   l_date := l_date + 1;
	 end loop;
    end if;
    EXCEPTION
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'TVE_ID',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END  Res_TPG_Delimited ;

  PROCEDURE Res_TPG_Delimited (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    p_tve_id                       IN NUMBER,
    p_start_date                   IN date,
    p_end_date                     IN date,
    p_cutoff_date                     IN date) IS
    item_not_found_error          EXCEPTION;
    l_row_notfound                 BOOLEAN := TRUE;
    l_month                       NUMBER := OKC_API.G_MISS_NUM;
    l_start_date1                  date := OKC_API.G_MISS_DATE;
    l_end_date1                    date := OKC_API.G_MISS_DATE;
    l_start_date                  date := OKC_API.G_MISS_DATE;
    l_end_date                    date := OKC_API.G_MISS_DATE;
    l_date                        date := OKC_API.G_MISS_DATE;
    x_task_id                     NUMBER;
    l_tze_name                    OKX_TIMEZONES_V.global_timezone_name%TYPE;
    CURSOR okc_tgd_csr (p_tve_id IN NUMBER)
    IS
      SELECT month, day, nth, day_of_week, hour, minute, second, tze_id
        FROM OKC_TIMEVALUES
       WHERE id = p_tve_id
		and  tve_type = 'TGD';
    l_okc_tgd_rec                 okc_tgd_csr%ROWTYPE;
    BEGIN

    /*
	 Resolve all generic dates e.g. Last day of every month or, 15th of every month etc.
    */

      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
	 /* Find the start and end dates if not passed and store them in l_start_date1 and l_end_date1 */
	 if (p_start_date is null or p_start_date = OKC_API.G_MISS_DATE) then
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'START_DATE');
        x_return_status := OKC_API.G_RET_STS_ERROR;
	   return;
	 elsif (p_end_date is null or p_end_date = OKC_API.G_MISS_DATE) then
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'END_DATE');
        x_return_status := OKC_API.G_RET_STS_ERROR;
	   return;
	 else
	   if p_start_date > p_end_date then
          x_return_status := OKC_API.G_RET_STS_ERROR;
          OKC_API.set_message(G_APP_NAME, 'OKC_INVALID_END_DATE');
	     return;
	   end if;
	   l_start_date1 := p_start_date;
	   l_end_date1 := p_end_date;
	 end if;
      OPEN okc_tgd_csr(p_tve_id);
      FETCH okc_tgd_csr INTO l_okc_tgd_rec;
      l_row_notfound := okc_tgd_csr%NOTFOUND;
      CLOSE okc_tgd_csr;
      IF (l_row_notfound) THEN
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TVE_ID');
        RAISE item_not_found_error;
      END IF;
	 if l_okc_tgd_rec.tze_id is NOT NULL and
	    l_okc_tgd_rec.tze_id <> OKC_API.G_MISS_NUM then
         Get_Timezone(l_okc_tgd_rec.tze_id, l_tze_name, x_return_status);
	    if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	      return;
	    end if;
	 else
	   l_tze_name := NULL;
	 end if;
      Res_TPG_Delimited (
        x_return_status,
        p_api_version,
        p_init_msg_list,
	   p_tve_id,
        l_okc_tgd_rec.tze_id,
        l_tze_name,
        l_okc_tgd_rec.month,
        l_okc_tgd_rec.day,
        l_okc_tgd_rec.nth,
        l_okc_tgd_rec.day_of_week,
        l_okc_tgd_rec.hour,
        l_okc_tgd_rec.minute,
        l_okc_tgd_rec.second,
        p_start_date,
        p_end_date,
	   p_cutoff_date) ;
    EXCEPTION
      WHEN item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'TVE_ID',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END  Res_TPG_Delimited ;

  PROCEDURE Res_Cycle (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    p_tve_id                       IN NUMBER,
    p_tze_id                       IN NUMBER,
    p_tze_name                       IN VARCHAR2,
    p_start_date                   IN date,
    p_end_date                     IN date,
    p_cutoff_date                     IN date) IS
    CURSOR okc_spn_csr (p_id                 IN NUMBER)
    IS
      SELECT id, active_yn, duration, uom_code
      FROM Okc_Span
      connect by prior id = spn_id
      start with ((spn_id is NULL) or (spn_id = OKC_API.G_MISS_NUM)) and
	   tve_id = p_id;
    type l_okc_spn_tbl_type is table of okc_spn_csr%ROWTYPE index by binary_integer;
    item_not_found_error          EXCEPTION;
    l_row_notfound                 BOOLEAN := TRUE;
    l_end_date                     date;
    l_start_date                   date;
    i                              NUMBER;
    l_okc_spn_tbl                  l_okc_spn_tbl_type;
    x_msg_count              NUMBER;
    x_msg_data               VARCHAR2(2000);
    x_task_id              NUMBER;
    BEGIN

    /*
	 Resolve all recurring dates e.g. Every 6 months
    */

      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
	 /* Find the start and end dates if not passed and store them in l_start_date1 and l_end_date1 */
	 if (p_start_date is null or p_start_date = OKC_API.G_MISS_DATE) then
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'START_DATE');
        x_return_status := OKC_API.G_RET_STS_ERROR;
	   return;
	 elsif (p_end_date is null or p_end_date = OKC_API.G_MISS_DATE) then
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'END_DATE');
        x_return_status := OKC_API.G_RET_STS_ERROR;
	   return;
	 else
	   if p_start_date > p_end_date then
          x_return_status := OKC_API.G_RET_STS_ERROR;
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'START_DATE');
	     return;
	   end if;
	 end if;
	 l_start_date := p_start_date;
	 l_end_date := p_start_date;

	 /* one recurring timevalue may comprise of many spans */

	 OPEN okc_spn_csr(p_tve_id);
	 i := 0;
	 LOOP
        FETCH okc_spn_csr INTO l_okc_spn_tbl(i);
        EXIT WHEN okc_spn_csr%NOTFOUND;
	   i:=i+1;
	 END LOOP;
      CLOSE okc_spn_csr;
      IF (l_okc_spn_tbl.COUNT > 0) THEN
        while l_end_date <= p_end_date
	   LOOP
          i := l_okc_spn_tbl.FIRST;
          LOOP
	       l_end_date := okc_time_util_pub.get_enddate(l_start_date, l_okc_spn_tbl(i).uom_code,l_okc_spn_tbl(i).duration);
	       if (l_end_date > p_end_date) THEN
		    exit;
		  end if;
		  if l_okc_spn_tbl(i).active_yn = 'Y' then
               Create_RTV_N_Tasks(
                 x_return_status,
                 p_api_version,
                 p_init_msg_list,
                 p_tve_id,
                 l_end_date,
			  p_cutoff_date,
	            NULL,
                 p_tze_id,
                 p_tze_name);
	          if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	           exit;
	          end if;
            end if;
		  if ((l_end_date - l_start_date) >= 1) then
		    l_start_date := l_end_date + 1;
		  else
		    l_start_date := l_end_date + (86399/86400);
		  end if;
            EXIT WHEN (i = l_okc_spn_tbl.LAST);
            i := l_okc_spn_tbl.NEXT(i);
	     END LOOP;
	     IF x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	       exit;
          END IF;
	     if (l_end_date > p_end_date) THEN
		  exit;
		end if;
        END LOOP;
	 ELSE
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SPN_ID');
	   return;
      END IF;
    EXCEPTION
      WHEN item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'TVE_ID',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END  Res_Cycle ;

-- The parameters p_resolved_until_date is the date till which the timevalues will be resolved
--                p_cutoff_date is the threshold date below which dates resolved will be ignored.
--  In other words dates will be resolved between p_cutoff_date and the least of (p_resolved_until_date,end date of K header/Line)


  PROCEDURE Res_Time_K(
    p_chr_id IN NUMBER,
    p_resolved_until_date IN DATE ,
    p_cutoff_date         IN DATE,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status OUT NOCOPY VARCHAR2) IS

     TYPE rule_csr_type is REF CURSOR;
	rule_csr rule_csr_type;

     TYPE tve_id_csr_type is REF CURSOR;
	tve_id_csr tve_id_csr_type;

-- The following cursor is changed to nvl for dates for Bug#2386569 regarding initialization for perpetual contracts
    CURSOR limited_by_csr(p_tve_id IN NUMBER) is
     select nvl(ise.start_date,to_date('01010001','ddmmyyyy')) start_date,
            nvl(ise.end_date,to_date('31124000','ddmmyyyy')) end_date,
                tze_id
      from okc_time_ia_startend_val_v ise
      where ise.id = p_tve_id;

    l_list_of_rules                VARCHAR2(4000);
    l_list_of_rules1               VARCHAR2(4000);
    l_list_of_tve_id               VARCHAR2(4000);
    l_row_not_found                BOOLEAN := TRUE;
    l_limited_by_rec               limited_by_csr%ROWTYPE;
    l_start_date                   DATE;
    l_end_date                     DATE;
    l_k_start_date                 DATE;
    l_k_end_date                   DATE;
    l_rul_id                       NUMBER;
    l_chr_id                       NUMBER;
    l_cle_id                       NUMBER;
    l_tve_id                       NUMBER;
    l_tve_id_limited               NUMBER;
    l_tve_type                     OKC_TIMEVALUES.tve_type%type;
    l_sql_string varchar2(4000);
    l_datetime                     date;
    x_msg_count              NUMBER;
    x_msg_data               VARCHAR2(2000);
    x_task_id              NUMBER;
    l_rule_type                    OKC_RULES_V.rule_information_category%type;
    l_app_id         number;
    l_rule_df_name   varchar2(40);
    l_col_val_table  OKC_TIME_UTIL_PUB.t_col_vals;
    l_no_of_cols     number;
    l_tze_id     number;
    l_tze_name                    OKX_TIMEZONES_V.global_timezone_name%TYPE;
    p_isev_ext_rec	              OKC_TIME_PUB.isev_ext_rec_type;
    x_isev_ext_rec	              OKC_TIME_PUB.isev_ext_rec_type;
    l_pending_further_resolving   VARCHAR2(1) := 'X';
    l_over_further_resolving   VARCHAR2(1) := 'X';

  BEGIN

    /*
	 Resolve all timevalues related to a contract (excluding the event ones).
    */

    /* Get the application_id and get the rule definition names */

    l_app_id := OKC_TIME_UTIL_PUB.get_app_id;
    if l_app_id is null then
      return;
    end if;

    l_rule_df_name := OKC_TIME_UTIL_PUB.get_rule_df_name;
    if l_rule_df_name is null then
      return;
    end if;

   /* Get all the rule types (e.g. NTN)  from metadata which are related to timevalues.*/
   /* Get all the rule types (e.g. NTN)  from metadata which are related to tasks.*/

    l_list_of_rules := OKC_TIME_UTIL_PUB.get_rule_defs_using_vs(l_app_id,l_rule_df_name,'OKC_TIMEVALUES');
    l_list_of_rules1 := OKC_TIME_UTIL_PUB.get_rule_defs_using_vs(l_app_id,l_rule_df_name,'OKC_TASK_RS');

    x_return_status     := OKC_API.G_RET_STS_SUCCESS;

    /* For these rules, get their ids using the contract header (line) id.               */

    l_sql_string := 'select r.id, rg.chr_id, rg.cle_id, r.rule_information_category ' ||
	 'from okc_rules_b r, okc_rule_groups_b rg '||
	 'where r.dnz_chr_id = :p_chr_id ' ||
	 'and rg.id = r.rgp_id ' ||
	 'and r.rule_information_category in '|| l_list_of_rules ||
	 'and r.rule_information_category in '|| l_list_of_rules1 ;
    open rule_csr for l_sql_string using p_chr_id;
    loop
      fetch rule_csr into l_rul_id, l_chr_id, l_cle_id, l_rule_type;
	 exit when rule_csr%NOTFOUND;

   /* Get all the timevalues associated with the rule. Currently there is only one tve_id per rule. May be extended in
	 future. API is flexible to handle this   */

      l_list_of_tve_id := OKC_TIME_UTIL_PUB.get_tve_ids(l_app_id,l_rule_df_name,l_rule_type,'OKC_TIMEVALUES',
                                                       l_rul_id);
      if l_list_of_tve_id is NULL Then
		goto next_row1;
      end if;
      l_sql_string :=
	 'select id, tve_id_limited, tve_type, datetime, tze_id ' ||
	 'from okc_timevalues ' ||
	 'where ((tve_type in ( ''TGD'',''TAV''))'||
	 ' or (tve_type = ''CYL'' and interval_yn = ''N'')) ' ||
	 'and id in '|| l_list_of_tve_id;
      open tve_id_csr for l_sql_string;
      loop
	   fetch tve_id_csr into l_tve_id, l_tve_id_limited, l_tve_type, l_datetime, l_tze_id;
	   exit when tve_id_csr%NOTFOUND;

	   /* Absolute Time Value will have only one date */

	  IF l_tve_type = 'TAV' then
	     if l_tze_id is NOT NULL and
	        l_tze_id <> OKC_API.G_MISS_NUM then
               Get_Timezone(l_tze_id, l_tze_name, x_return_status);
	       if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	         exit;
	       end if;
	     else
	      l_tze_name := NULL;
	     end if;
             Create_RTV_N_Tasks(
               x_return_status,
               p_api_version,
               p_init_msg_list,
               l_tve_id,
               l_datetime,
	       p_cutoff_date,
	       NULL,
               l_tze_id,
               l_tze_name);
	    if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	      exit;
	    end if;
	    goto next_row;
	  end if;

       /* If timevalue is not limited use the Contract headers and lines effectivity */

	   IF l_tve_id_limited is NULL or
	      l_tve_id_limited = OKC_API.G_MISS_NUM then
             Get_K_Effectivity(
               l_chr_id,
               l_cle_id,
               l_start_date,
               l_end_date,
               x_return_status);
	      if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	        exit;
	      end if;
             IF l_cle_id is NOT NULL and
	         l_cle_id <> OKC_API.G_MISS_NUM Then
		    null;
 	     ELSIF l_chr_id is NOT NULL and
	         l_chr_id <> OKC_API.G_MISS_NUM Then

       /* If the contract is perpetual or for a very large duration, resolve this only until the derived
		resolved until date to avoid too many resolved timevalues being created. this check has to be
		done for each rule tied to a contract header.
	   */

	         if l_end_date >= p_resolved_until_date Then
	           l_pending_further_resolving := '1';
		 elsif l_end_date < p_resolved_until_date Then
	           l_over_further_resolving := '1';
                 end if;
	      end if;
	      if l_end_date > p_resolved_until_date then
		    l_end_date := p_resolved_until_date;
              end if;

		 /* For generic and recurring call the respective procedures to create resolved timevalues */
              if l_start_date <= p_resolved_until_date then

		 If l_tve_type = 'TGD' then
                    Res_TPG_Delimited ( x_return_status,p_api_version,p_init_msg_list,l_tve_id, l_start_date, l_end_date, p_cutoff_date);
		 elsif l_tve_type = 'CYL' then
                    Res_Cycle ( x_return_status,p_api_version,p_init_msg_list,l_tve_id, l_tze_id, l_tze_name, l_start_date, l_end_date, p_cutoff_date);
		 end if;
	         if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	           exit;
	         end if;
	       end if;
        ELSE

       /* If timevalue is limited get the effectivity of the timevalue using tve_id_limited */

          OPEN limited_by_csr(l_tve_id_limited);
          FETCH limited_by_csr into l_limited_by_rec;
          l_row_not_found := limited_by_csr%NOTFOUND;
          CLOSE limited_by_csr;
          IF (l_row_not_found) THEN
            OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TVE_ID');
            x_return_status := OKC_API.G_RET_STS_ERROR;
          ELSE
            l_start_date := l_limited_by_rec.start_date;
            l_end_date   := l_limited_by_rec.end_date;

		  /*
		  A timevalue is created using the timevalue editor for an unsigned contract such that the start date is null
		  (assuming to be the start of the contract) but the end date is a valid limiting date (not the end date of the
		  contract). In order to store that as a tve_id_limited, the start_date can be set to the start_date of the
		  contract header/line. But the contract is not yet signed, therfore a change to the start_date would mean a
		  change in the start date of the tve_id_limited.
		  In order to overcome this problem, we are storing the start_date as 01010001 and we will update this to the
		  actual start date of the contract once the contract is signed/approved and this procedure is called.
		  The same can be said to be the reason for storing end_date as 31124000 where the end_date is entered as null
		  but the start date is an actual limiting date.

		  BETTER SOLUTION: Change datamodel to have the K effectivity pointing to a timevalue and then the limited
		  timevalue will also be pointing to the same start date as referenced by the contract start date.
            */

	   if l_start_date = to_date('01010001','ddmmyyyy') or
	      l_end_date = to_date('31124000','ddmmyyyy') Then
              Get_K_Effectivity(
                l_chr_id,
                l_cle_id,
                l_k_start_date,
                l_k_end_date,
                x_return_status);
	      if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	           exit;
	      end if;
	      if l_start_date = to_date('01010001','ddmmyyyy') Then
		      l_start_date := l_k_start_date;
                      if l_start_date > l_end_date Then
                         l_start_date := l_end_date;
                      end if;
	      end if;
	      if l_end_date = to_date('31124000','ddmmyyyy') Then
		      l_end_date := l_k_end_date;
                      if l_start_date > l_end_date Then
                         l_end_date := l_start_date;
                      end if;
	      end if;
              p_isev_ext_rec.start_date := l_start_date;
              p_isev_ext_rec.end_date :=  l_end_date;
	      p_isev_ext_rec.id := l_tve_id_limited;
              OKC_TIME_pub.update_ia_startend(
                p_api_version,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_isev_ext_rec,
                x_isev_ext_rec);
              if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
                exit;
              end if;
            end if;

		  /* For contract headers, if the end date > derived resolved until date, use the derived_resolved until date
			as a limiting date for time resolving timevalue and also update the contract header to reflect this value.
			Otherwise reset the resolved until date of the contract header to NULL
			*/

            IF l_cle_id is NOT NULL and
	          l_cle_id <> OKC_API.G_MISS_NUM Then
		  null;
	    ELSIF l_chr_id is NOT NULL and
	          l_chr_id <> OKC_API.G_MISS_NUM Then
	          if l_end_date > p_resolved_until_date Then
	            l_pending_further_resolving := '1';
		  elsif l_end_date < p_resolved_until_date Then
	            l_over_further_resolving := '1';
                  end if;
	    end if;
	    if l_end_date > p_resolved_until_date then
		    l_end_date := p_resolved_until_date;
            end if;

		 /* For generic and recurring call the respective procedures to create resolved timevalues */
            if l_start_date <= p_resolved_until_date then

		  If l_tve_type = 'TGD' then
                     Res_TPG_Delimited ( x_return_status,p_api_version,p_init_msg_list,l_tve_id, l_start_date, l_end_date, p_cutoff_date);
		  elsif l_tve_type = 'CYL' then
                     Res_Cycle ( x_return_status,p_api_version,p_init_msg_list,l_tve_id, l_tze_id, l_tze_name, l_start_date, l_end_date, p_cutoff_date);
		  end if;
	          if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	            exit;
	          end if;
	     end if;
          END IF;
        END IF;
	   <<next_row>>
		null;
       end loop;
       close tve_id_csr;
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
         exit;
       END IF;
	 <<next_row1>>
		null;
      end loop;
      close rule_csr;
      if l_pending_further_resolving = '1' Then
	   update okc_k_headers_b
	     set resolved_until = p_resolved_until_date
	     where id = l_chr_id;
	 elsif l_over_further_resolving = '1' Then
	   update okc_k_headers_b
	     set resolved_until = NULL
	     where id = l_chr_id;
	 end if;
      l_pending_further_resolving  := 'X';
      l_over_further_resolving  := 'X';
      EXCEPTION
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'CHR_ID',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Res_Time_K;

  PROCEDURE Res_Time_New_K(
    p_chr_id IN NUMBER,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    Res_Time_K(p_chr_id => p_chr_id,
			p_resolved_until_date => add_months(sysdate,(OKC_TIME_RES_PVT.RESOLVE_UNTIL_MONTHS +
											     OKC_TIME_RES_PVT.PICKUP_UPTO_MONTHS)) ,
			p_cutoff_date => sysdate,
			p_api_version => p_api_version,
			p_init_msg_list => p_init_msg_list,
			x_return_status => x_return_status);
    END Res_Time_New_K;

  PROCEDURE Res_Time_Extnd_K(
    p_chr_id IN NUMBER,
    p_cle_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status OUT NOCOPY VARCHAR2) IS

    TYPE rgp_csr_type is REF CURSOR;
    rgp_csr rgp_csr_type;

    TYPE tve_id_csr_type is REF CURSOR;
    tve_id_csr tve_id_csr_type;

-- The following cursor is changed to nvl for dates for Bug#2386569 regarding initialization for perpetual contracts
    CURSOR limited_by_csr(p_tve_id IN NUMBER) is
     select nvl(ise.start_date,to_date('01010001','ddmmyyyy')) start_date,
            nvl(ise.end_date,to_date('31124000','ddmmyyyy')) end_date,
            tze_id
      from okc_time_ia_startend_val_v ise
      where ise.id = p_tve_id;


    CURSOR resolved_until_csr(p_cle_id IN NUMBER) is
	 SELECT resolved_until from okc_k_headers_b h, okc_k_lines_b l
	 where h.id = l.chr_id
	   and l.id = p_cle_id;

    l_list_of_rules                VARCHAR2(4000);
    l_list_of_rules1               VARCHAR2(4000);
    l_list_of_tve_id               VARCHAR2(4000);
    l_row_not_found                BOOLEAN := TRUE;
    l_tve_id                       NUMBER;
    l_rul_id                       NUMBER;
    l_tve_type                     OKC_TIMEVALUES.tve_type%type;
    l_datetime                     date;
    x_msg_count              NUMBER;
    x_msg_data               VARCHAR2(2000);
    l_sql_string varchar2(4000);
    l_rule_type                    OKC_RULES_V.rule_information_category%type;
    l_app_id         number;
    l_rule_df_name   varchar2(40);
    l_col_val_table  OKC_TIME_UTIL_PUB.t_col_vals;
    l_no_of_cols     number;
    l_tze_id     number;
    x_task_id              NUMBER;
    l_tze_name                    OKX_TIMEZONES_V.global_timezone_name%TYPE;
    l_resolved_until_date         DATE;
    l_cutoff_date                 DATE := NULL;
    l_end_date                    DATE;
    l_start_date                    DATE;
    l_tve_id_limited               NUMBER;
    l_limited_by_rec               limited_by_csr%ROWTYPE;
    l_pending_further_resolving   VARCHAR2(1) := 'X';
    l_over_further_resolving   VARCHAR2(1) := 'X';

  BEGIN

    /*
	 Call this procedure for extending lines and headers.
	 NOTE: Extending header will not automatically resolve timevalues for lines. Has to be called for extending lines
	 as well.  p_chr_id and p_cle_id are mutually exclusive.
    */

    l_end_date := nvl(p_end_date, to_date('12314000','mmddyyyy'));
    l_cutoff_date := p_start_date;
    x_return_status     := OKC_API.G_RET_STS_SUCCESS;

    /* Get the application_id and get the rule definition names */

    l_app_id := OKC_TIME_UTIL_PUB.get_app_id;
    if l_app_id is null then
      return;
    end if;
    l_rule_df_name := OKC_TIME_UTIL_PUB.get_rule_df_name;
    if l_rule_df_name is null then
      return;
    end if;

/*get all the rule types (e.g. NTN)  from metadata which are related to timevalues.*/
/*get all the rule types (e.g. NTN)  from metadata which are related to tasks.*/

    l_list_of_rules := OKC_TIME_UTIL_PUB.get_rule_defs_using_vs(l_app_id,l_rule_df_name,'OKC_TIMEVALUES');
    l_list_of_rules1 := OKC_TIME_UTIL_PUB.get_rule_defs_using_vs(l_app_id,l_rule_df_name,'OKC_TASK_RS');

    /* For these rules, get their ids using the contract header (line) id.               */


    l_sql_string := 'select r.id, r.rule_information_category ' ||
	 'from okc_rules_b r, okc_rule_groups_b rg '||
	 'where ((rg.dnz_chr_id = :p_chr_id and rg.cle_id IS NULL) or ' ||
	 '	 (rg.cle_id = :p_cle_id)) and ' ||
	 '	  r.rgp_id = rg.id ' ||
	 'and r.rule_information_category in '|| l_list_of_rules ||
	 'and r.rule_information_category in '|| l_list_of_rules1 ;

	 /* for extending lines, ensure that the resolved until date (if present) of the headers is met */

    if p_cle_id is NOT NULL AND
       p_cle_id <> OKC_API.G_MISS_NUM Then
      OPEN resolved_until_csr(p_cle_id);
      FETCH resolved_until_csr INTO l_resolved_until_date;
      CLOSE resolved_until_csr;
      IF l_resolved_until_date is NOT NULL then
        if l_end_date > l_resolved_until_date then
	      l_end_date := l_resolved_until_date;
        end if;
	 end if;
    elsif p_chr_id is NOT NULL AND
          p_chr_id <> OKC_API.G_MISS_NUM Then
      l_resolved_until_date := add_months(sysdate,OKC_TIME_RES_PVT.RESOLVE_UNTIL_MONTHS);
      if l_end_date <= l_resolved_until_date then
	   l_over_further_resolving := '1';
      else
	    l_end_date := l_resolved_until_date;
	    l_pending_further_resolving := '1';
      end if;
    end if;
    open rgp_csr for l_sql_string using p_chr_id, p_cle_id;
    loop
      FETCH rgp_csr into l_rul_id, l_rule_type;
	 exit when rgp_csr%NOTFOUND;

   /* Get all the timevalues associated with the rule. Currently there is only one tve_id per rule. May be extended in
	 future. API is flexible to handle this   */

      l_list_of_tve_id := OKC_TIME_UTIL_PUB.get_tve_ids(l_app_id,l_rule_df_name,l_rule_type,'OKC_TIMEVALUES',
                                                       l_rul_id);
      if l_list_of_tve_id is NULL Then
		goto next_row;
	 end if;
      l_sql_string :=
	 'select id, tve_id_limited, tve_type, datetime, tze_id ' ||
	 'from okc_timevalues ' ||
	 'where ((tve_type in ( ''TGD'',''TAV''))'||
	 ' or (tve_type = ''CYL'' and interval_yn = ''N'')) ' ||
	 'and id in '|| l_list_of_tve_id;
      open tve_id_csr for l_sql_string;
	 loop
	   fetch tve_id_csr into l_tve_id, l_tve_id_limited, l_tve_type, l_datetime, l_tze_id;
	   exit when tve_id_csr%NOTFOUND;
	   /* Absolute Time Value will have only one date */

	   IF l_tve_type = 'TAV' then
	     if l_tze_id is NOT NULL and
	        l_tze_id <> OKC_API.G_MISS_NUM then
            Get_Timezone(l_tze_id, l_tze_name, x_return_status);
	       if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	         exit;
	       end if;
	    else
	      l_tze_name := NULL;
	    end if;
         Create_RTV_N_Tasks(
           x_return_status,
           p_api_version,
           p_init_msg_list,
           l_tve_id,
           l_datetime,
		 l_cutoff_date,
	      NULL,
           l_tze_id,
           l_tze_name);
	    if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	      exit;
	    end if;

		 /* For generic and recurring call the respective procedures to create resolved timevalues */
       ELSE
	    l_start_date := p_start_date;
	    if l_tve_id_limited is NOT NULL Then
               OPEN limited_by_csr(l_tve_id_limited);
               FETCH limited_by_csr into l_limited_by_rec;
               l_row_not_found := limited_by_csr%NOTFOUND;
               CLOSE limited_by_csr;
               IF (l_row_not_found) THEN
                 OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TVE_ID');
                 x_return_status := OKC_API.G_RET_STS_ERROR;
	         exit;
               END IF;
               if l_limited_by_rec.start_date > p_start_date Then
			 l_start_date := l_limited_by_rec.start_date;
	       end if;
	       if l_limited_by_rec.end_date < l_end_date Then
                   l_end_date   := l_limited_by_rec.end_date;
	       end if;
	    end if;
	    if l_start_date > l_end_date then
		 exit;
	    end if;
	    l_cutoff_date := l_start_date;
	    IF l_tve_type = 'TGD' then
              Res_TPG_Delimited ( x_return_status,p_api_version,p_init_msg_list,l_tve_id, l_start_date, l_end_date, l_cutoff_date);
	    ELSE
              Res_Cycle ( x_return_status,p_api_version,p_init_msg_list,l_tve_id, l_tze_id, l_tze_name, l_start_date, l_end_date, l_cutoff_date);
	    end if;
	  end if;
	  if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	      exit;
	  end if;
	 end loop;
	 close tve_id_csr;
	 IF x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	    exit;
      END IF;
	<<next_row>>
	    null;
    end loop;
    if l_pending_further_resolving = '1' Then
	   update okc_k_headers_b
	     set resolved_until = l_resolved_until_date
	     where id = p_chr_id;
    elsif l_over_further_resolving = '1' Then
	   update okc_k_headers_b
	     set resolved_until = NULL
	     where id = p_chr_id;
    end if;
    l_pending_further_resolving  := 'X';
    l_over_further_resolving  := 'X';
    CLOSE rgp_csr;
    EXCEPTION
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'CHR_ID',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Res_Time_Extnd_K;

  PROCEDURE Res_Time_Termnt_K(
    p_chr_id IN NUMBER,
    p_cle_id IN NUMBER,
    p_end_date IN DATE,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status OUT NOCOPY VARCHAR2) IS

    TYPE rgp_csr_type is REF CURSOR;
    rgp_csr rgp_csr_type;

    TYPE tve_id_csr_type is REF CURSOR;
    tve_id_csr tve_id_csr_type;

    CURSOR resolved_until_csr(p_chr_id IN NUMBER) is
	 SELECT resolved_until from okc_k_headers_b h
	 where h.id = p_chr_id;

    l_list_of_rules                VARCHAR2(4000);
    l_list_of_rules1               VARCHAR2(4000);
    l_list_of_tve_id               VARCHAR2(4000);
    l_row_not_found                BOOLEAN := TRUE;
    l_tve_id                       NUMBER;
    l_rul_id                       NUMBER;
    l_rtv_id                       NUMBER;
    l_tve_type                     OKC_TIMEVALUES.tve_type%type;
    l_sql_string varchar2(4000);
    l_rtvv_rec                     OKC_TIME_PUB.rtvv_rec_type;
    x_msg_count              NUMBER;
    x_msg_data               VARCHAR2(2000);
    l_app_id         number;
    l_rule_type                    OKC_RULES_V.rule_information_category%type;
    l_rule_df_name   varchar2(40);
    l_col_val_table  OKC_TIME_UTIL_PUB.t_col_vals;
    l_no_of_cols     number;
    l_resolved_until_date     date;

  BEGIN

    /*
	 Call this procedure for terminating lines and headers.
	 NOTE: terminating header will not automatically delete resolved timevalues for lines.
	 Has to be called for terminating lines as well.  p_chr_id and p_cle_id are mutually exclusive.
    */

    x_return_status     := OKC_API.G_RET_STS_SUCCESS;

    /* Get the application_id and get the rule definition names */

    l_app_id := OKC_TIME_UTIL_PUB.get_app_id;
    if l_app_id is null then
      return;
    end if;

    l_rule_df_name := OKC_TIME_UTIL_PUB.get_rule_df_name;
    if l_rule_df_name is null then
      return;
    end if;

/*get all the rule types (e.g. NTN)  from metadata which are related to timevalues.*/
/*get all the rule types (e.g. NTN)  from metadata which are related to tasks.*/

    l_list_of_rules := OKC_TIME_UTIL_PUB.get_rule_defs_using_vs(l_app_id,l_rule_df_name,'OKC_TIMEVALUES');
    l_list_of_rules1 := OKC_TIME_UTIL_PUB.get_rule_defs_using_vs(l_app_id,l_rule_df_name,'OKC_TASK_RS');

    /* For these rules, get their ids using the contract header (line) id.               */

    l_sql_string := 'select r.id, r.rule_information_category ' ||
	 'from okc_rules_b r, okc_rule_groups_b rg '||
	 'where ((rg.dnz_chr_id = :p_chr_id and rg.cle_id IS NULL) or ' ||
	 '	 (rg.cle_id = :p_cle_id)) and ' ||
	 '	  r.rgp_id = rg.id ' ||
	 'and r.rule_information_category in '|| l_list_of_rules ||
	 'and r.rule_information_category in '|| l_list_of_rules1 ;
    open rgp_csr for l_sql_string using p_chr_id, p_cle_id;
    loop
      FETCH rgp_csr into l_rul_id, l_rule_type;
	 exit when rgp_csr%NOTFOUND;

   /* Get all the timevalues associated with the rule. Currently there is only one tve_id per rule. May be extended in
	 future. API is flexible to handle this   */

      l_list_of_tve_id := OKC_TIME_UTIL_PUB.get_tve_ids(l_app_id,l_rule_df_name,l_rule_type,'OKC_TIMEVALUES',
                                                       l_rul_id);
      if l_list_of_tve_id is NULL Then
		goto next_row;
	 end if;

	 /* Get all resolved timevalues */

      l_sql_string :=
	 'select rtv.id rtv_id ' ||
	 'from okc_timevalues tve, okc_resolved_timevalues rtv ' ||
	 'where rtv.tve_id = tve.id ' ||
	 'and rtv.datetime >= :p_end_date  ' ||
	 'and tve.id in '|| l_list_of_tve_id ;
      open tve_id_csr for l_sql_string using p_end_date;
	 loop
	   fetch tve_id_csr into l_rtv_id;
	   exit when tve_id_csr%NOTFOUND;
	   l_rtvv_rec.id := l_rtv_id;
	   OKC_TASK_PUB.DELETE_TASK(
          p_api_version,
          p_init_msg_list,
	     'F',
          NULL,
	     l_rtv_id,
          x_return_status,
          x_msg_count,
          x_msg_data);
	   if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     exit;
	   end if;
	   OKC_TIME_PUB.DELETE_RESOLVED_TIMEVALUES(
          p_api_version,
          p_init_msg_list,
          x_return_status,
          x_msg_count,
          x_msg_data,
          l_rtvv_rec);
	   if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     exit;
	   end if;
	 end loop;
	 close tve_id_csr;
	 IF x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	    exit;
      END IF;
	 <<next_row>>
	   null;
    end loop;
    CLOSE rgp_csr;

    /* For contract headers, check if the contract has a resolved until date. If it exists, then check if this date is >
	  termination date (p_end_date). If yes, then reset the resolved until date as there is no need for any further
	  resolving of timevalues */

    if p_chr_id is NOT NULL AND
       p_chr_id <> OKC_API.G_MISS_NUM Then
      OPEN resolved_until_csr(p_chr_id);
      FETCH resolved_until_csr INTO l_resolved_until_date;
      CLOSE resolved_until_csr;
      IF l_resolved_until_date is NOT NULL then
        if p_end_date <= l_resolved_until_date then
	      update okc_k_headers_b
	         set resolved_until = NULL
	      where id = p_chr_id;
        end if;
      end if;
    end if;
    EXCEPTION
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'CHR_ID',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Res_Time_Termnt_K;

  FUNCTION Check_Res_Time_N_tasks(
	  p_tve_id IN NUMBER,
	  p_date IN DATE)
	 return BOOLEAN IS
	 l_dummy    VARCHAR2(1) ;
	 l_rowfound BOOLEAN := TRUE;

-- Replaced name with seeded id to avoid transaltion issue - Bug 1683539
-- Reed OKCSCHRULE - Contract Schedule Rule - Bug 1683539
	 CURSOR Check_RTV_Tasks_csr (p_tve_id IN NUMBER, p_date IN DATE) IS
	  SELECT '1' from OKC_RESOLVED_TIMEVALUES
	  WHERE tve_id = p_tve_id AND
	   datetime <= p_date
	  UNION ALL
	   SELECT '1' from OKC_RESOLVED_TIMEVALUES rtv, JTF_TASKS_B t, JTF_TASK_TYPES_VL tt
	   WHERE SOURCE_OBJECT_ID = rtv.id AND
		    t.TASK_TYPE_ID = tt.TASK_TYPE_ID AND
		    tve_id = p_tve_id AND
		    tt.task_type_id = 23 AND
		    --tt.name = 'OKCSCHRULE' AND
		    ACTUAL_START_DATE <= p_date;
	 BEGIN
	  OPEN Check_RTV_Tasks_csr(p_tve_id, p_date);
	  FETCH Check_RTV_Tasks_csr into l_dummy;
	  l_rowfound := Check_RTV_Tasks_csr%FOUND;
	  CLOSE Check_RTV_Tasks_csr;
	  return l_rowfound;

    END Check_Res_Time_N_tasks;

  PROCEDURE Delete_Res_Time_N_Tasks(
    p_tve_id IN NUMBER,
    p_date IN DATE,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status OUT NOCOPY VARCHAR2) IS

    CURSOR rtv_csr(p_tve_id IN NUMBER, p_date IN DATE) is
	 select rtv.id rtv_id
	 from okc_timevalues tve, okc_resolved_timevalues rtv
	 where rtv.tve_id = tve.id
	 and rtv.datetime >= p_date
	 and tve.id = p_tve_id ;

    l_rtv_rec                      rtv_csr%ROWTYPE;
    l_rtvv_rec                     OKC_TIME_PUB.rtvv_rec_type;
    x_msg_count              NUMBER;
    x_msg_data               VARCHAR2(2000);
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    open rtv_csr (p_tve_id, p_date);
    loop
      fetch rtv_csr into l_rtv_rec;
	 exit when rtv_csr%NOTFOUND;
	 l_rtvv_rec.id := l_rtv_rec.rtv_id;
	 OKC_TASK_PUB.DELETE_TASK(
        p_api_version,
        p_init_msg_list,
	   'F',
        NULL,
	   l_rtv_rec.rtv_id,
        x_return_status,
        x_msg_count,
        x_msg_data);
	 if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	   exit;
	 end if;
	 OKC_TIME_PUB.DELETE_RESOLVED_TIMEVALUES(
        p_api_version,
        p_init_msg_list,
        x_return_status,
        x_msg_count,
        x_msg_data,
        l_rtvv_rec);
	 if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	   exit;
	 end if;
    end loop;
    close rtv_csr;
    EXCEPTION
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'RTV_ID',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Delete_Res_Time_N_Tasks;

  PROCEDURE Create_Res_Time_N_Tasks(
    p_tve_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE ,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status OUT NOCOPY VARCHAR2) IS

    CURSOR tve_id_csr(p_tve_id IN NUMBER) is
	 select id, tve_type, datetime, tze_id
	 from okc_timevalues
	 where
	  id = p_tve_id;

    l_tve_rec                      tve_id_csr%ROWTYPE;
    x_msg_count              NUMBER;
    x_msg_data               VARCHAR2(2000);
    x_task_id              NUMBER;
    l_tze_name                    OKX_TIMEZONES_V.global_timezone_name%TYPE;
    l_row_not_found                BOOLEAN := TRUE;
    l_cutoff_date                  DATE := NULL;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    open tve_id_csr(p_tve_id);
    fetch tve_id_csr into l_tve_rec;
    l_row_not_found := tve_id_csr%NOTFOUND;
    close tve_id_csr;
    if l_row_not_found then
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TVE_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	 return;
    end if;
    IF l_tve_rec.tve_type = 'TAV' then
	  if l_tve_rec.tze_id is NOT NULL and
	     l_tve_rec.tze_id <> OKC_API.G_MISS_NUM then
         Get_Timezone(l_tve_rec.tze_id, l_tze_name, x_return_status);
	    if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	      return;
	    end if;
	  else
	    l_tze_name := NULL;
	  end if;
       Create_RTV_N_Tasks(
         x_return_status,
         p_api_version,
         p_init_msg_list,
         l_tve_rec.id,
         l_tve_rec.datetime,
	    l_cutoff_date,
	    NULL,
         l_tve_rec.tze_id,
         l_tze_name);
	  if x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	    return;
	  end if;
	  ELSIF l_tve_rec.tve_type = 'TGD' then
         Res_TPG_Delimited ( x_return_status,p_api_version,p_init_msg_list,l_tve_rec.id, p_start_date, p_end_date, l_cutoff_date);
	  ELSIF l_tve_rec.tve_type = 'CYL' then
         Res_Cycle ( x_return_status,p_api_version,p_init_msg_list,l_tve_rec.id, l_tve_rec.tze_id, l_tze_name, p_start_date, p_end_date, l_cutoff_date);
	  end if;
    EXCEPTION
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'TVE_ID',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Create_Res_Time_N_Tasks;

  PROCEDURE Batch_Resolve_Time_N_Tasks IS
   CURSOR c_chr IS
	SELECT contract_number, id, resolved_until from OKC_K_HEADERS_B
	where resolved_until < add_months(sysdate, OKC_TIME_RES_PVT.PICKUP_UPTO_MONTHS)
	   and resolved_until >= sysdate;
   x_return_status VARCHAR2(1);
   l_init_msg_list VARCHAR2(1) := 'F';
   l_api_version  NUMBER := 1.0;
   l_resolved_until_date DATE;
   BEGIN

   /* This is a nightly concurrent job to trigger re-resoving all
	 contracts which need re-resolving as their resolved until_date
	 falls in the PICKUP_UPTO_MONTHS window.
	 If the end date is less than the derived resolved until date,
	 reset the resolved until dates for the contract
    	 to null and will never be picked up.
	*/

--    l_resolved_until_date := add_months(sysdate, OKC_TIME_RES_PVT.RESOLVE_UNTIL_MONTHS);
    for chr_rec in c_chr LOOP
      l_resolved_until_date := add_months(chr_rec.resolved_until, OKC_TIME_RES_PVT.RESOLVE_UNTIL_MONTHS);
      Res_Time_K(p_chr_id => chr_rec.id,
			p_resolved_until_date => l_resolved_until_date,
			p_cutoff_date => chr_rec.resolved_until,
			p_api_version => l_api_version,
			p_init_msg_list => l_init_msg_list,
			x_return_status => x_return_status);
	end loop;
  END Batch_Resolve_Time_N_Tasks;

 PROCEDURE time_resolver(errbuf  OUT NOCOPY VARCHAR2,
                         retcode OUT NOCOPY VARCHAR2) IS

  l_api_name        CONSTANT VARCHAR2(30) := 'time_resolver';
  l_api_version     CONSTANT VARCHAR2(30) := 1.0;
  l_return_status   VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  x_return_status   VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(1000);
  l_init_msg_list   VARCHAR2(3) := 'F';
  E_Resource_Busy   EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy,  -00054);

  BEGIN
       -- call start_activity to create savepoint, check comptability
       -- and initialize message list
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,l_init_msg_list
                                                ,'_PROCESS'
                                                ,x_return_status
                                                );
    --Initialize the return code
    retcode := 0;

    OKC_TIME_RES_PVT.Batch_Resolve_Time_N_Tasks;

	IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             	RAISE OKC_API.G_EXCEPTION_ERROR;
 --	ELSIF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
--		     commit;
     END IF;

	 OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);

  EXCEPTION
      WHEN E_Resource_Busy THEN
        l_return_status := okc_api.g_ret_sts_error;
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
	retcode := 2;
	errbuf  := substr(sqlerrm,1,200);
        l_return_status := OKC_API.HANDLE_EXCEPTIONS
        (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        l_msg_count,
        l_msg_data,
        '_COMPLEX');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	retcode := 2;
	errbuf  := substr(sqlerrm,1,200);
        l_return_status := OKC_API.HANDLE_EXCEPTIONS
        (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        l_msg_count,
        l_msg_data,
        '_COMPLEX');
       WHEN OTHERS THEN
	retcode := 2;
	errbuf  := substr(sqlerrm,1,200);
        l_return_status := OKC_API.HANDLE_EXCEPTIONS
        (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        l_msg_count,
        l_msg_data,
        '_COMPLEX');
  END time_resolver;

END OKC_TIME_RES_PVT;

/
