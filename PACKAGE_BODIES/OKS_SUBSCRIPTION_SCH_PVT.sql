--------------------------------------------------------
--  DDL for Package Body OKS_SUBSCRIPTION_SCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_SUBSCRIPTION_SCH_PVT" AS
/* $Header: OKSSBSHB.pls 120.0 2005/05/25 18:34:34 appldev noship $ */


Procedure Fill_var_num(p_def               in   varchar2,
                         p_type              in   varchar2,
                         x_var_num_tbl       out  NOCOPY var_tbl,
                         x_return_status     OUT  NOCOPY Varchar2) ;

Procedure Create_Yearly_tbl(
      p_start_dt               IN       date
,     p_end_dt                 IN       date
,     p_offset_dy              IN       NUMBER
,     p_freq                   IN       Varchar2
,     p_yr_pattern_tbl         IN       var_tbl
,     x_rec_tbl                IN OUT   NOCOPY del_tbl
,     x_return_status          OUT      NOCOPY Varchar2
);


Procedure Create_Monthly_tbl(
      p_start_dt               IN       date
,     p_end_dt                 IN       date
,     p_offset_dy              IN       NUMBER
,     p_freq                   IN       Varchar2
,     p_mth_pattern_tbl        IN       var_tbl
,     p_yr_pattern_tbl         IN       var_tbl
,     x_rec_tbl                IN OUT   NOCOPY del_tbl
,     x_return_status          OUT      NOCOPY Varchar2
);

Procedure Create_Weekly_tbl(
      p_start_dt               IN       date
,     p_end_dt                 IN       date
,     p_offset_dy              IN       NUMBER
,     p_freq                   IN       Varchar2
,     p_mth_pattern_tbl        IN       var_tbl
,     p_yr_pattern_tbl         IN       var_tbl
,     p_wk_pattern_tbl         IN       var_tbl
,     x_rec_tbl                IN OUT   NOCOPY del_tbl
,     x_return_status          OUT      NOCOPY Varchar2
);



Procedure Create_wday_tbl(
      p_start_dt               IN       date
,     p_end_dt                 IN       date
,     p_offset_dy              IN       NUMBER
,     p_freq                   IN       Varchar2
,     p_mth_pattern_tbl        IN       var_tbl
,     p_yr_pattern_tbl         IN       var_tbl
,     p_wk_pattern_tbl         IN       var_tbl
,     p_wd_pattern_tbl         IN       var_tbl
,     x_rec_tbl                IN OUT   NOCOPY del_tbl
,     x_return_status          OUT      NOCOPY Varchar2
);


Procedure Create_day_tbl(
      p_start_dt               IN       date
,     p_end_dt                 IN       date
,     p_offset_dy              IN       NUMBER
,     p_freq                   IN       Varchar2
,     p_mth_pattern_tbl        IN       var_tbl
,     p_yr_pattern_tbl         IN       var_tbl
,     p_day_pattern_tbl        IN       var_tbl
,     x_rec_tbl                IN OUT   NOCOPY del_tbl
,     x_return_status          OUT      NOCOPY Varchar2
);








Procedure Calc_Delivery_date
(
      p_start_dt	       IN    date
,     p_end_dt                 IN    date
,     p_offset_dy              IN    NUMBER
,     p_freq                   IN    Varchar2
,     p_pattern_tbl            IN    pattern_tbl
,     x_delivery_tbl           OUT   NOCOPY del_tbl
,     x_return_status          OUT   NOCOPY Varchar2
) IS

l_type            varchar2(20);
l_def             varchar2(100);
l_info_tbl        var_tbl;
l_rec_tbl         del_tbl;
l_yr_tbl          var_tbl;
l_mth_tbl         var_tbl;
l_wk_tbl          var_tbl;
l_wdy_tbl         var_tbl;
l_dy_tbl          var_tbl;
l_low_yr          varchar2(4);
l_high_yr         varchar2(4);
l_ind             number;

BEGIN

x_return_status := OKC_API.G_RET_STS_SUCCESS;

If p_start_dt > p_end_dt THEN
   RETURN;
END IF;


if p_pattern_tbl.count <= 0 THEN
  RETURN;
END IF;

-----errorout_ad('p_pattern_tbl.count = ' || p_pattern_tbl.count);

FOR I IN 1..p_pattern_tbl.count
LOOP

    IF i = 1 THEN
      l_ind := p_pattern_tbl.FIRST;
    ELSE
      l_ind := p_pattern_tbl.next(l_ind);

    END IF;

    IF p_pattern_tbl(l_ind).yr_pattern = '*' THEN

       SELECT TO_CHAR(p_start_dt,'YYYY') INTO l_low_yr FROM DUAL;
       SELECT TO_CHAR(p_end_dt,'YYYY') INTO l_high_yr FROM DUAL;

       if l_low_yr = l_high_yr THEN
          l_def :=  l_low_yr;
       ELSE

          l_def := l_low_yr || '-' || l_high_yr ;
       END IF;

    ELSE
       l_def := p_pattern_tbl(l_ind).yr_pattern;
    END IF;
    -----errorout_ad('l_def passed for year tbl = ' || l_def);

    Fill_var_num(
          p_def            => l_def,
          p_type           => 'YR',
          x_var_num_tbl    => l_yr_tbl,
          x_return_status  => x_return_status);

    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'YEAR PATTERN NOT BUILD.');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -----errorout_ad('l_yr_tbl count = ' || l_yr_tbl.count);

    IF p_freq = 'Y' THEN

        Create_Yearly_tbl(
                p_start_dt              => p_start_dt,
                p_end_dt                => p_end_dt,
                p_offset_dy             => nvl(p_offset_dy,0),
                p_freq                  => p_freq,
                p_yr_pattern_tbl        => l_yr_tbl,
                x_rec_tbl               => l_rec_tbl,
                x_return_status         => x_return_status);

       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'YEARLY SCHEDULE NOT BUILD.');
           RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

    ELSE       ---p_freq <> 'Y'

       Fill_var_num(
           p_def            => p_pattern_tbl(l_ind).mth_pattern,
           p_type           => 'MTH',
           x_var_num_tbl    => l_mth_tbl,
           x_return_status  => x_return_status);


       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'MONTH PATTERN NOT BUILD.');
           RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
        -----errorout_ad('l_mth_tbl count = ' || l_mth_tbl.count);

       IF p_freq = 'M' THEN

            Create_Monthly_tbl(
                   p_start_dt              => p_start_dt,
                   p_end_dt                => p_end_dt,
                   p_offset_dy             => nvl(p_offset_dy,0),
                   p_freq                  => p_freq,
                   p_mth_pattern_tbl       => l_mth_tbl,
                   p_yr_pattern_tbl        => l_yr_tbl,
                   x_rec_tbl               => l_rec_tbl,
                   x_return_status         => x_return_status);

            IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
               OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'MONTHLY SCHEDULE NOT BUILD.');
               RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

       ELSIF p_freq = 'W' THEN

           Fill_var_num(
                   p_def            => p_pattern_tbl(l_ind).week_pattern,
                   p_type           => 'WK',
                   x_var_num_tbl    => l_wk_tbl,
                   x_return_status  => x_return_status);

           IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
               OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'WEEKLY PATTERN NOT BUILD.');
               RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;

            Create_Weekly_tbl(
                  p_start_dt               => p_start_dt,
                  p_end_dt                 => p_end_dt,
                  p_offset_dy              => nvl(p_offset_dy,0),
                  p_freq                   => p_freq,
                  p_mth_pattern_tbl        => l_mth_tbl,
                  p_yr_pattern_tbl         => l_yr_tbl,
                  p_wk_pattern_tbl         => l_wk_tbl,
                  x_rec_tbl                => l_rec_tbl,
                  x_return_status          => x_return_status);

            IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
               OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'WEEKLY SCHEDULE NOT BUILD.');
               RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

         ELSIF p_freq = 'D' THEN

            IF p_pattern_tbl(l_ind).day_pattern IS NOT NULL THEN     ---then wk and wdy will be null.
               Fill_var_num(
                   p_def            => p_pattern_tbl(l_ind).day_pattern,
                   p_type           => 'DY',
                   x_var_num_tbl    => l_dy_tbl,
                   x_return_status  => x_return_status);

               IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                  OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'DAILY PATTERN NOT BUILD.');
                  RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF;

               Create_day_tbl(
                       p_start_dt               => p_start_dt,
                       p_end_dt                 => p_end_dt,
                       p_offset_dy              => nvl(p_offset_dy,0),
                       p_freq                   => p_freq,
                       p_mth_pattern_tbl        => l_mth_tbl,
                       p_yr_pattern_tbl         => l_yr_tbl,
                       p_day_pattern_tbl        => l_dy_tbl,
                       x_rec_tbl                => l_rec_tbl,
                       x_return_status          => x_return_status);

               IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                 OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'DAILY SCHEDULE NOT BUILD.');
                  RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF;

            ELSE                     ---day pattern is null
                Fill_var_num(
                   p_def            => p_pattern_tbl(l_ind).week_pattern,
                   p_type           => 'WK',
                   x_var_num_tbl    => l_wk_tbl,
                   x_return_status  => x_return_status);

                IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                  OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'WEEKLY PATTERN NOT BUILD.');
                  RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;


                Fill_var_num(
                   p_def            => p_pattern_tbl(l_ind).wday_pattern,
                   p_type           => 'WDY',
                   x_var_num_tbl    => l_wdy_tbl,
                   x_return_status  => x_return_status);

                IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                  OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'WEEK DAY PATTERN NOT BUILD.');
                  RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;


                Create_wday_tbl(
                       p_start_dt               => p_start_dt,
                       p_end_dt                 => p_end_dt,
                       p_offset_dy              => nvl(p_offset_dy,0),
                       p_freq                   => p_freq,
                       p_mth_pattern_tbl        => l_mth_tbl,
                       p_yr_pattern_tbl         => l_yr_tbl,
                       p_wk_pattern_tbl         => l_wk_tbl,
                       p_wd_pattern_tbl         => l_wdy_tbl,
                       x_rec_tbl                => l_rec_tbl,
                       x_return_status          => x_return_status);

                 IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'WEEK DAY SCHEDULE NOT BUILD.');
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                 END IF;

             END IF;           --end of day_pattern IS NOT NULL

        END IF;         ----end of p_freq
   END IF;       ---end of p_freq <> 'Y'
END LOOP;



-----errorout_ad('Create TBL status = ' || x_return_status);
-----errorout_ad('l_rec_tbl count outside loop = '|| l_rec_tbl.count);

if l_rec_tbl.count > 0 then


 FOR i IN 1..l_rec_tbl.count LOOP

  IF i = 1 THEN
    l_ind := l_rec_tbl.FIRST;
  ELSE
    l_ind := l_rec_tbl.next(l_ind);
  END IF;

  x_delivery_tbl(i).delivery_date  := l_rec_tbl(l_ind).delivery_date;
  x_delivery_tbl(i).start_date     := l_rec_tbl(l_ind).start_date;
  x_delivery_tbl(i).end_date       := l_rec_tbl(l_ind).end_date;

  -----errorout_ad('delivery_date = ' || l_rec_tbl(l_ind).delivery_date);

  /*just for test
  INSERT INTO Oks_test_tbl
    (delivery_date,start_date,end_date)
    values  (l_rec_tbl(l_ind).delivery_date,l_rec_tbl(l_ind).start_date,l_rec_tbl(l_ind).end_date);*/

 END LOOP;
end if;


EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

END  Calc_Delivery_date;



Procedure Fill_var_num(p_def               in   varchar2,
                         p_type              in   varchar2,
                         x_var_num_tbl       out  NOCOPY var_tbl,
                         x_return_status     OUT  NOCOPY Varchar2)
IS

l_value        varchar2(20);
l_rem_def     varchar2(100);
l_len         number;
l_pos         number;
l_pos_hypen   number;
l_hypen_str   varchar2(50);
i             number;
l_low_val     number;
l_high_val    number;

BEGIN

x_return_status := OKC_API.G_RET_STS_SUCCESS;

i := 1;

IF p_def IS NULL THEN
   RETURN;
END IF;

IF p_def = '*' THEN
   i := 1;
   if p_type = 'MTH' THEN
     l_low_val  := 1;
     l_high_val := 12;
   ELSif p_type = 'WK' THEN
     l_low_val  := 1;
     l_high_val := 5;
   ELSif p_type = 'WDY' THEN
     l_low_val  := 1;
     l_high_val := 7;

   ELSif p_type = 'DY' THEN
     l_low_val  := 1;
     l_high_val := 31;
   END IF;

   for val in l_low_val..l_high_val loop

     IF val < 10 THEN
        x_var_num_tbl(i).num_item  := '0' || TO_CHAR(val);
     ELSE
        x_var_num_tbl(i).num_item  := TO_CHAR(val);
     END IF;
     i := i + 1;
   end loop;
   -----errorout_ad('x_var_num_tbl.COUNT = ' || x_var_num_tbl.COUNT);
   return;
end if;

l_rem_def := p_def;

l_len := length(l_rem_def) ;

if l_len = 0 then
   return;
end if;

loop

  -----errorout_ad('l_rem_def = ' || l_rem_def);

  l_pos := instr(l_rem_def,',', 1,1);

  -----errorout_ad('l_pos = ' || l_pos);
  if l_pos = 0 then

     l_pos_hypen := instr(l_rem_def,'-', 1,1);

     if l_pos_hypen = 0 then
        -----errorout_ad('coming in ');
        IF TO_NUMBER(l_rem_def) < 10 and LENGTH(l_rem_def) = 1 THEN
           x_var_num_tbl(i).num_item  := '0' || l_rem_def;
        ELSE
           x_var_num_tbl(i).num_item  :=  l_rem_def;
        END IF;
        i := i + 1;
     else

       l_low_val  := to_number(substr(l_rem_def,1, (l_pos_hypen - 1)));

       l_high_val := to_number(substr(l_rem_def, (l_pos_hypen +1),(l_len-l_pos_hypen)));

       for val in l_low_val..l_high_val loop
         IF val < 10 AND LENGTH(TO_CHAR(val)) = 1 THEN
           x_var_num_tbl(i).num_item  := '0' || TO_CHAR(val);
         ELSE
           x_var_num_tbl(i).num_item  := TO_CHAR(val);
         END IF;

         i := i + 1;
       end loop;
     end if;               ----end of l_pos_hypen=0
     l_len := 0;

  else        ----l_pos > 0


     l_value := substr(l_rem_def,1, (l_pos - 1));

     -----errorout_ad('l_value = ' || l_value);

     l_pos_hypen := instr(l_value,'-', 1,1);

     if l_pos_hypen = 0 then

        IF to_number(l_value) < 10 AND LENGTH(l_value) = 1 THEN
          x_var_num_tbl(i).num_item  := '0' || l_value;
        ELSE
          x_var_num_tbl(i).num_item  := l_value;
        END IF;

        i := i + 1;
     else

       l_low_val  := to_number(substr(l_value,1, (l_pos_hypen - 1)));

       l_high_val := to_number(substr(l_value, (l_pos_hypen +1),(length(l_value)-l_pos_hypen)));

       for val in l_low_val..l_high_val loop
         IF val < 10 AND LENGTH(TO_CHAR(val)) = 1 THEN
           x_var_num_tbl(i).num_item  := '0' || TO_CHAR(val);
         ELSE
           x_var_num_tbl(i).num_item  := TO_CHAR(val);
         END IF;
         i := i + 1;
       end loop;


     end if;               ----end of l_pos_hypen=0
     l_value := substr(l_rem_def, (l_pos + 1), (l_len-l_pos));  --remaing string

     l_rem_def := l_value;
     l_len := length(l_rem_def) ;



  END IF;               ----end of l_pos = 0
  EXIT WHEN l_pos <= 0;

end loop;

EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

end Fill_var_num;

Procedure Create_Yearly_tbl(
      p_start_dt               IN       date
,     p_end_dt                 IN       date
,     p_offset_dy              IN       NUMBER
,     p_freq                   IN       Varchar2
,     p_yr_pattern_tbl         IN       var_tbl
,     x_rec_tbl                IN OUT   NOCOPY del_tbl
,     x_return_status          OUT      NOCOPY Varchar2
)

IS

l_dt_str       VARCHAR2(10);
l_act_dt       DATE;
l_index        NUMBER;


BEGIN

x_return_status := OKC_API.G_RET_STS_SUCCESS;

IF (p_yr_pattern_tbl.COUNT = 0) THEN
  RETURN;
END IF;

FOR l_yr IN p_yr_pattern_tbl.FIRST..p_yr_pattern_tbl.LAST
LOOP

   l_dt_str := p_yr_pattern_tbl(l_yr).num_item || '0101' ;
   -----errorout_ad('l_dt_str = ' || l_dt_str);

   l_index := to_number(l_dt_str) + p_offset_dy;


   l_act_dt := TO_DATE(l_dt_str, 'YYYYMMDD');
   -----errorout_ad('l_act_dt = ' || l_act_dt);


   IF (l_act_dt < p_start_dt) OR (l_act_dt > p_end_dt) THEN
      NULL;

   ELSE

      IF NOT x_rec_tbl.EXISTS(l_index) then
        -----errorout_ad('index doe not exist = ' || l_index);
        IF (l_act_dt + p_offset_dy) < p_start_dt THEN
            x_rec_tbl(l_index).delivery_date := p_start_dt;
        ELSIF (l_act_dt + p_offset_dy) > p_end_dt THEN
            x_rec_tbl(l_index).delivery_date := p_end_dt;
        ELSE
            x_rec_tbl(l_index).delivery_date := l_act_dt + p_offset_dy;
        END IF;
        x_rec_tbl(l_index).start_date  := l_act_dt;
        x_rec_tbl(l_index).end_date    := TO_DATE(p_yr_pattern_tbl(l_yr).num_item || '1231', 'YYYYMMDD');

      END IF;         ---end of already exists.
   END IF;

END LOOP;            ---YR LOOP

EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;



END Create_Yearly_tbl;



Procedure Create_Monthly_tbl(
      p_start_dt               IN       date
,     p_end_dt                 IN       date
,     p_offset_dy              IN       NUMBER
,     p_freq                   IN       Varchar2
,     p_mth_pattern_tbl        IN       var_tbl
,     p_yr_pattern_tbl         IN       var_tbl
,     x_rec_tbl                IN OUT   NOCOPY  del_tbl
,     x_return_status          OUT      NOCOPY Varchar2
)

IS

l_dt_str       VARCHAR2(10);
l_act_dt       DATE;
l_index        NUMBER;
l_mth_last_dt  date;


BEGIN

x_return_status := OKC_API.G_RET_STS_SUCCESS;

IF (p_yr_pattern_tbl.COUNT = 0) OR (p_mth_pattern_tbl.COUNT = 0 ) THEN
  RETURN;
END IF;

FOR l_yr IN p_yr_pattern_tbl.FIRST..p_yr_pattern_tbl.LAST
LOOP

    FOR l_mth IN p_mth_pattern_tbl.FIRST..p_mth_pattern_tbl.LAST
    LOOP
       l_dt_str := p_yr_pattern_tbl(l_yr).num_item || p_mth_pattern_tbl(l_mth).num_item || '01' ;
       -----errorout_ad('l_dt_str = ' || l_dt_str);

       l_index := to_number(l_dt_str) + p_offset_dy;


       l_act_dt := TO_DATE(l_dt_str, 'YYYYMMDD');
       -----errorout_ad('l_act_dt = ' || l_act_dt);


       IF (l_act_dt < p_start_dt) OR (l_act_dt > p_end_dt) THEN
          NULL;

       ELSE

          IF NOT x_rec_tbl.EXISTS(l_index) then
              -----errorout_ad('index doe not exist = ' || l_index);
              IF (l_act_dt + p_offset_dy) < p_start_dt THEN
                x_rec_tbl(l_index).delivery_date := p_start_dt;
              ELSIF (l_act_dt + p_offset_dy) > p_end_dt THEN
                x_rec_tbl(l_index).delivery_date := p_end_dt;
              ELSE
                x_rec_tbl(l_index).delivery_date := l_act_dt + p_offset_dy;
              END IF;

              SELECT LAST_DAY(l_act_dt) INTO l_mth_last_dt FROM dual;
              x_rec_tbl(l_index).start_date  := l_act_dt;
              x_rec_tbl(l_index).end_date    := l_mth_last_dt;

          END IF;         ---end of already exists.
       END IF;

     END LOOP;         ---MTH LOOP
END LOOP;            ---YR LOOP

EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;



END Create_Monthly_tbl;


Procedure Create_Weekly_tbl(
      p_start_dt               IN       date
,     p_end_dt                 IN       date
,     p_offset_dy              IN       NUMBER
,     p_freq                   IN       Varchar2
,     p_mth_pattern_tbl        IN       var_tbl
,     p_yr_pattern_tbl         IN       var_tbl
,     p_wk_pattern_tbl         IN       var_tbl
,     x_rec_tbl                IN OUT   NOCOPY del_tbl
,     x_return_status          OUT      NOCOPY Varchar2
)
IS

l_mth_yr       VARCHAR2(6);
l_act_dt       DATE;
l_index        NUMBER;


BEGIN

x_return_status := OKC_API.G_RET_STS_SUCCESS;

IF (p_yr_pattern_tbl.COUNT = 0) OR (p_mth_pattern_tbl.COUNT = 0 ) OR (p_wk_pattern_tbl.COUNT = 0) THEN
  RETURN;
END IF;

FOR l_yr IN p_yr_pattern_tbl.FIRST..p_yr_pattern_tbl.LAST LOOP

    FOR l_mth IN p_mth_pattern_tbl.FIRST..p_mth_pattern_tbl.LAST LOOP

       FOR l_wk IN p_wk_pattern_tbl.FIRST..p_wk_pattern_tbl.LAST LOOP

         l_mth_yr :=  p_mth_pattern_tbl(l_mth).num_item || p_yr_pattern_tbl(l_yr).num_item ;

         l_act_dt := GET_WD_DATE(mmyyyy => l_mth_yr,
                                 week   => TO_NUMBER(p_wk_pattern_tbl(l_wk).num_item),
                                 dow    => 1) ;

         ---dow harcoded for sunday

        IF l_act_dt IS NOT NULL THEN

          l_index := to_number(TO_CHAR(l_act_dt,'YYYYMMDD')) + p_offset_dy;


          IF (l_act_dt < p_start_dt) OR (l_act_dt > p_end_dt) THEN
             NULL;

          ELSE

            IF NOT x_rec_tbl.EXISTS(l_index) then

                IF (l_act_dt + p_offset_dy) < p_start_dt THEN
                  x_rec_tbl(l_index).delivery_date:= p_start_dt;
                ELSIF (l_act_dt + p_offset_dy) > p_end_dt THEN
                  x_rec_tbl(l_index).delivery_date := p_end_dt;
                ELSE
                  x_rec_tbl(l_index).delivery_date := l_act_dt + p_offset_dy;
                END IF;

                x_rec_tbl(l_index).start_date  := l_act_dt;             --start of wk sunday
                x_rec_tbl(l_index).end_date    := l_act_dt + 6;         ---end of wk sat.
            end if;   --end of already exists.

          END IF;  ---end of l_act_dt < p_start_dt) OR (l_act_dt > p_end_dt)

         END IF;       ---l_act_dt null

     END LOOP;       --WK LOOP
   END LOOP;         ---MTH LOOP
END LOOP;            ---YR LOOP

EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;



END Create_Weekly_tbl;

Procedure Create_day_tbl(
      p_start_dt               IN       date
,     p_end_dt                 IN       date
,     p_offset_dy              IN    NUMBER
,     p_freq                   IN       Varchar2
,     p_mth_pattern_tbl        IN       var_tbl
,     p_yr_pattern_tbl         IN       var_tbl
,     p_day_pattern_tbl        IN       var_tbl
,     x_rec_tbl                IN OUT   NOCOPY del_tbl
,     x_return_status          OUT      NOCOPY Varchar2
)
IS
l_dt_str       VARCHAR2(10);
l_act_dt       DATE;
l_index        NUMBER;
l_first_dt     VARCHAR2(8);
l_last_dt      DATE;
l_max          VARCHAR2(10);


BEGIN

x_return_status := OKC_API.G_RET_STS_SUCCESS;

IF (p_yr_pattern_tbl.COUNT = 0) OR (p_mth_pattern_tbl.COUNT = 0 ) OR (p_day_pattern_tbl.COUNT = 0) THEN
  RETURN;
END IF;

FOR l_yr IN p_yr_pattern_tbl.FIRST..p_yr_pattern_tbl.LAST LOOP

    FOR l_mth IN p_mth_pattern_tbl.FIRST..p_mth_pattern_tbl.LAST LOOP

        l_first_dt :=  p_yr_pattern_tbl(l_yr).num_item || p_mth_pattern_tbl(l_mth).num_item || '01';

        SELECT LAST_DAY(TO_DATE(l_first_dt,'YYYYMMDD')) INTO l_last_dt FROM dual;      --last day of mth

        l_max := TO_CHAR(l_last_dt,'YYYYMMDD');

      FOR l_dy IN p_day_pattern_tbl.FIRST..p_day_pattern_tbl.LAST LOOP

       l_dt_str := p_yr_pattern_tbl(l_yr).num_item || p_mth_pattern_tbl(l_mth).num_item
                   || p_day_pattern_tbl(l_dy).num_item ;

       l_index := to_number(l_dt_str) + p_offset_dy;

       IF TO_NUMBER(l_max) < TO_NUMBER(l_dt_str) THEN        --dt_str is greater then last date of mth
          NULL;
       ELSE
          l_act_dt := TO_DATE(l_dt_str, 'YYYYMMDD');


          IF (l_act_dt < p_start_dt) OR (l_act_dt > p_end_dt) THEN
             NULL;

          ELSE

            IF NOT x_rec_tbl.EXISTS(l_index) then


              IF (l_act_dt + p_offset_dy) < p_start_dt THEN
                x_rec_tbl(l_index).delivery_date := p_start_dt;
              ELSIF (l_act_dt + p_offset_dy) > p_end_dt THEN
                x_rec_tbl(l_index).delivery_date := p_end_dt;
              ELSE
                x_rec_tbl(l_index).delivery_date := l_act_dt + p_offset_dy;
              END IF;
              ---start and end date will be date without offset
              x_rec_tbl(l_index).start_date  := l_act_dt;
              x_rec_tbl(l_index).end_date    := l_act_dt;
            END IF; ---end of chk if l_index item already exists.
          END IF;

        END IF;      ---end of dt should not pass beyond last dy of mth
     END LOOP;     ----day loop
   END LOOP;         ---MTH LOOP
END LOOP;            ---YR LOOP

EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;



END Create_Day_tbl;

Procedure Create_wday_tbl(
      p_start_dt               IN       date
,     p_end_dt                 IN       date
,     p_offset_dy              IN       NUMBER
,     p_freq                   IN       Varchar2
,     p_mth_pattern_tbl        IN       var_tbl
,     p_yr_pattern_tbl         IN       var_tbl
,     p_wk_pattern_tbl         IN       var_tbl
,     p_wd_pattern_tbl         IN       var_tbl
,     x_rec_tbl                IN OUT   NOCOPY del_tbl
,     x_return_status          OUT      NOCOPY Varchar2
)
IS

l_mth_yr       VARCHAR2(6);
l_act_dt       DATE;
l_index        NUMBER;


BEGIN

x_return_status := OKC_API.G_RET_STS_SUCCESS;

IF (p_yr_pattern_tbl.COUNT = 0) OR (p_mth_pattern_tbl.COUNT = 0 ) OR (p_wk_pattern_tbl.COUNT = 0) or
    (p_wd_pattern_tbl.count = 0)THEN

  RETURN;
END IF;

FOR l_yr IN p_yr_pattern_tbl.FIRST..p_yr_pattern_tbl.LAST LOOP

    FOR l_mth IN p_mth_pattern_tbl.FIRST..p_mth_pattern_tbl.LAST LOOP

       FOR l_wk IN p_wk_pattern_tbl.FIRST..p_wk_pattern_tbl.LAST LOOP

          FOR l_wdy IN p_wd_pattern_tbl.FIRST..p_wd_pattern_tbl.LAST LOOP



            l_mth_yr :=  p_mth_pattern_tbl(l_mth).num_item || p_yr_pattern_tbl(l_yr).num_item ;

            l_act_dt := GET_WD_DATE(mmyyyy => l_mth_yr,
                                    week   => TO_NUMBER(p_wk_pattern_tbl(l_wk).num_item),
                                    dow    => TO_NUMBER(p_wd_pattern_tbl(l_wdy).num_item) );

            ---dow number from wday pattern tbl and sunday = 1

            IF l_act_dt IS NOT NULL THEN       ---that day of week exists in month

               l_index := to_number(TO_CHAR(l_act_dt,'YYYYMMDD')) + p_offset_dy;


               IF (l_act_dt < p_start_dt) OR (l_act_dt > p_end_dt) THEN
                  NULL;

               ELSE

                  IF NOT x_rec_tbl.EXISTS(l_index) then

                     IF (l_act_dt + p_offset_dy) < p_start_dt THEN
                       x_rec_tbl(l_index).delivery_date := p_start_dt;
                     ELSIF (l_act_dt + p_offset_dy) > p_end_dt THEN
                       x_rec_tbl(l_index).delivery_date := p_end_dt;
                     ELSE
                       x_rec_tbl(l_index).delivery_date := l_act_dt + p_offset_dy;
                     END IF;
                     ---start and end date will be date without offset
                     x_rec_tbl(l_index).start_date  := l_act_dt;
                     x_rec_tbl(l_index).end_date    := l_act_dt;
                  END IF;   --end of already exists.

               END IF;  ---end of l_act_dt < p_start_dt) OR (l_act_dt > p_end_dt)

            END IF;       ---l_act_dt null

       END LOOP;     --wday loop

     END LOOP;       --WK LOOP
   END LOOP;         ---MTH LOOP
END LOOP;            ---YR LOOP

EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;



END Create_Wday_tbl;





FUNCTION GET_WD_DATE(mmyyyy IN VARCHAR2,
                       week  IN NUMBER,
                       dow   IN NUMBER) RETURN DATE
IS
first_weekday NUMBER;
first_dow DATE;
retdate DATE;



BEGIN
first_weekday := to_char(to_date('01'||mmyyyy,'DDMMYYYY'),'D');

if first_weekday <= dow then
  first_dow     := to_date('01'||mmyyyy,'DDMMYYYY')+ (dow-first_weekday);

else
  first_dow     := to_date('01'||mmyyyy,'DDMMYYYY')+ (dow-first_weekday+7);

end if;

retdate := first_dow + ((week-1)*7);


If to_char(retdate,'MMYYYY') <> mmyyyy Then
  retdate := NULL;
End If;

return retdate;


END GET_WD_DATE;

end OKS_SUBSCRIPTION_SCH_PVT;

/
