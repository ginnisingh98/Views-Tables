--------------------------------------------------------
--  DDL for Package Body PAY_USER_COLUMN_INSTANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_USER_COLUMN_INSTANCES_PKG" as
/* $Header: pyusi01t.pkb 115.0 99/07/17 06:44:37 porting ship $ */
--
--
  procedure insert_row(p_rowid			 in out varchar2,
                       p_user_column_instance_id in out number,
                       p_effective_start_date    in date,
                       p_effective_end_date      in date,
                       p_user_row_id             in number,
                       p_user_column_id          in number,
                       p_business_group_id       in number,
                       p_legislation_code        in varchar2,
                       p_legislation_subgroup    in varchar2,
                       p_value                   in varchar2 )  is
  --
  cursor c1 is
      select pay_user_column_instances_s.nextval
      from   sys.dual ;

  cursor c2 is
      select rowid
      from   pay_user_column_instances_f
      where  user_column_instance_id  = p_user_column_instance_id ;
  --
  begin
  --
    open c1 ;
    fetch c1 into p_user_column_instance_id ;
    close c1 ;

    insert into PAY_USER_COLUMN_INSTANCES_F
    ( USER_COLUMN_INSTANCE_ID,
      EFFECTIVE_START_DATE,
      EFFECTIVE_END_DATE,
      USER_ROW_ID,
      USER_COLUMN_ID,
      BUSINESS_GROUP_ID,
      LEGISLATION_CODE,
      LEGISLATION_SUBGROUP,
      VALUE )
    values ( p_user_column_instance_id ,
             p_effective_start_date ,
             p_effective_end_date ,
             p_user_row_id ,
             p_user_column_id ,
             p_business_group_id ,
             p_legislation_code ,
             p_legislation_subgroup ,
             p_value ) ;

--
     open c2 ;
     fetch c2 into p_rowid ;
     close c2 ;
--
  end insert_row ;
--
  procedure update_row(p_rowid			 in varchar2,
                       p_user_column_instance_id in number,
                       p_effective_start_date    in date,
                       p_effective_end_date      in date,
                       p_user_row_id             in number,
                       p_user_column_id          in number,
                       p_business_group_id       in number,
                       p_legislation_code        in varchar2,
                       p_legislation_subgroup    in varchar2,
                       p_value                   in varchar2 )  is
  begin
  --
   update PAY_USER_COLUMN_INSTANCES_F
   set    USER_COLUMN_INSTANCE_ID = p_user_column_instance_id,
          EFFECTIVE_START_DATE    = p_effective_start_date ,
          EFFECTIVE_END_DATE      = p_effective_end_date ,
          USER_ROW_ID		  = p_user_row_id,
          USER_COLUMN_ID	  = p_user_column_id,
          BUSINESS_GROUP_ID       = p_business_group_id,
          LEGISLATION_CODE        = p_legislation_code ,
          LEGISLATION_SUBGROUP    = p_legislation_subgroup,
          VALUE                   = p_value
   where  ROWID = p_rowid;
  --
  end update_row;
--
  procedure delete_row(p_rowid   in varchar2) is
  --
  begin
  --
    delete from PAY_USER_COLUMN_INSTANCES_F
    where  ROWID = p_rowid;
  --
  end delete_row;
--
  procedure lock_row (p_rowid                   in varchar2,
                      p_user_column_instance_id in number,
                      p_effective_start_date    in date,
                      p_effective_end_date      in date,
                      p_user_row_id             in number,
                      p_user_column_id          in number,
                      p_business_group_id       in number,
                      p_legislation_code        in varchar2,
                      p_legislation_subgroup    in varchar2,
                      p_value                   in varchar2 ) is
  --
    cursor C is select *
                from   PAY_USER_COLUMN_INSTANCES_F
                where  rowid = p_rowid
                for update of USER_COLUMN_INSTANCE_ID NOWAIT ;
  --
    rowinfo  C%rowtype;
  --
  begin
  --
    open C;
    fetch C into rowinfo;
    close C;
    --
    rowinfo.legislation_code := rtrim(rowinfo.legislation_code);
    rowinfo.legislation_subgroup := rtrim(rowinfo.legislation_subgroup);
    rowinfo.value := rtrim(rowinfo.value);
    --
    if ( (rowinfo.USER_COLUMN_INSTANCE_ID = p_user_column_instance_id )
     or  (rowinfo.USER_COLUMN_INSTANCE_ID is null and p_user_column_instance_id
	  is null ))
    and( (rowinfo.EFFECTIVE_START_DATE = p_effective_start_date)
     or  (rowinfo.EFFECTIVE_START_DATE is null and p_effective_start_date
	  is null ))
    and( (rowinfo.EFFECTIVE_END_DATE = p_effective_end_date)
     or  (rowinfo.EFFECTIVE_END_DATE is null and p_effective_end_date
	  is null ))
    and( (rowinfo.USER_ROW_ID = p_user_row_id )
     or  (rowinfo.USER_ROW_ID is null and p_user_row_id is null ))
    and( (rowinfo.USER_COLUMN_ID = p_user_column_id )
     or  (rowinfo.USER_COLUMN_ID is null and p_user_column_id is null ))
    and( (rowinfo.BUSINESS_GROUP_ID = p_business_group_id )
     or  (rowinfo.BUSINESS_GROUP_ID is null and p_business_group_id
	  is null ))
    and( (rowinfo.LEGISLATION_CODE = p_legislation_code )
     or  (rowinfo.LEGISLATION_CODE is null and p_legislation_code
	  is null ))
    and( (rowinfo.LEGISLATION_SUBGROUP = p_legislation_subgroup )
     or  (rowinfo.LEGISLATION_SUBGROUP is null and p_legislation_subgroup
	  is null ))
    and( (rowinfo.VALUE = p_value )
     or  (rowinfo.VALUE is null and p_value is null ))
    then
       return ;
    else
       fnd_message.set_name( 'FND' , 'FORM_RECORD_CHANGED');
       app_exception.raise_exception ;
    end if;
  end lock_row;
--
function latest_end_date ( p_user_row_id in number ) return date is
cursor c1 is
   select max(effective_end_date)
   from   pay_user_rows_f
   where  user_row_id = p_user_row_id ;
l_return_value date := null ;
begin
--
  open c1 ;
  fetch c1 into l_return_value ;
  close c1 ;
--
  return ( l_return_value ) ;
end ;
--
end PAY_USER_COLUMN_INSTANCES_PKG ;

/
