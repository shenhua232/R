create table wd_bor_base
as
SELECT t.u_id 用户标识,
       t1.MOBILE 手机,
       t1.login_name 登录名,
       t1.USER_NAME 展示名,
       t.cid 分站,
       t.NUM_ATTESTAITON 授信材料数量,
       t.NUM_PAWN 抵押物数量,
       t.BID_MUM 累计积分,
       --length(translate(t1.id_number,'0123456789Xx'||t1.id_number,'0123456789Xx'))=18
       (case when length(translate(substr(t1.id_number,7,8),'0123456789'||substr(t1.id_number,7,8),'0123456789'))=8
           and to_number(translate(substr(t1.id_number,7,4),'0123456789'||substr(t1.id_number,7,4),'0123456789'))>=1900
           and to_number(translate(substr(t1.id_number,11,2),'0123456789'||substr(t1.id_number,11,2),'0123456789'))<=12 then 
       trunc(months_between(sysdate,to_date(translate(substr(t1.id_number,7,8),'0123456789'||substr(t1.id_number,7,8),'0123456789')))/12) else null end) age,
       t1.MARRIAGE 婚姻状况,
       t1.EDUCATION 学历,
       --decode(t1.ANNUAL_INCOME,0,null,t1.ANNUAL_INCOME) 年收入,
       t1.ANNUAL_INCOME 年收入,
       --replace(t1.occupation,' ','')
       t1.occupation 职业,
       t1.ishave 资产情况,
       t1.STATUS,
       t1.ID_NUMBER 身份证号码,
       t1.WAY 注册来源,
       t1.uid_sale 业务员,
       t1.CREATE_TIME 创建时间,
       t1.QQ 备注
   FROM ods.u_borrower t
   LEFT JOIN ods.u_base t1 ON t.u_id=t1.U_ID
   WHERE t1.U_ID IS NOT null
   ;

   SELECT t1.id_number,translate(t1.id_number,'0123456789Xx'||t1.id_number,'0123456789Xx'),to_date(substr(translate(t1.id_number,'0123456789Xx'||t1.id_number,'0123456789Xx'),7,8))
   FROM ods.u_borrower t
   LEFT JOIN ods.u_base t1 ON t.u_id=t1.U_ID
   WHERE t1.U_ID IS NOT null
   and to_char(t1.create_time,'yyyy-mm-dd')>='2016-01-01'
   AND translate(t1.id_number,'#0123456789Xx','#') is not null;
   
   select translate('234slfjx','#0123456789X','#') from dual;
   select translate(substr(t1.id_number,7,8),'0123456789'||substr(t1.id_number,7,8),'0123456789')
   ,to_date(translate(substr(t1.id_number,7,8),'0123456789'||substr(t1.id_number,7,8),'0123456789')) 
   from ods.u_base t1
   where way=3
   and length(translate(substr(t1.id_number,7,8),'0123456789'||substr(t1.id_number,7,8),'0123456789'))=8;
   select to_date('89862716') from dual;
   
   
   select id_number,translate(substr(t1.id_number,7,8),'0123456789'||substr(t1.id_number,7,8),'0123456789') from ods.u_base t1
   where length(translate(substr(t1.id_number,7,8),'0123456789'||substr(t1.id_number,7,8),'0123456789'))=8
   and to_number(translate(substr(t1.id_number,7,4),'0123456789'||substr(t1.id_number,7,4),'0123456789'))>=1900
   and to_number(translate(substr(t1.id_number,9,2),'0123456789'||substr(t1.id_number,9,2),'0123456789'))<=12
 ;
 
 
 
 select t.u_id,t.name,
       t.appraisement 评估价值,
       t.loan_quota 贷款额度,
       t.status 审核状态,
       t.VERIFY_TIME 审核时间,
       t.VERIFY_USER 审核人,
       t.create_time 创建时间,
       t.is_installment 是否按揭,
       t.pawn_type 抵押类型,
       t.mileage 公里数,
       t.buy_money 购买价格,
       appraiser 评估师,
       t.plate_number 车牌号/*,
       t.reg_year||t.reg_month 注册时间,
       t.is_trailer 是否被拖车,
       t.trailer_time 拖车时间,
       trailer_status 拖车状态,
       trailer_sub_status 拖车子状态*/
from ods.u_pbi t
where t.appraisement>0
 
;


select * from ods.u_pbi t
;

truncate table wd_bor_pbi
;
insert into wd_bor_pbi
select t.u_id,
       t.name,
       t.appraisement 评估价值,
       t.loan_quota 贷款额度,
       t.status 审核状态,
       t.VERIFY_TIME 审核时间,
       t.VERIFY_USER 审核人,
       t.create_time 创建时间,
       t.is_installment 是否按揭,
       t.pawn_type 抵押类型,
       t.mileage 公里数,
       t.buy_money 购买价格,
       appraiser 评估师,
       t.plate_number 车牌号    
from (
select t.u_id,
       t.name,
       t.appraisement,
       t.loan_quota,
       t.status,
       t.VERIFY_TIME,
       t.VERIFY_USER,
       t.create_time,
       t.is_installment,
       t.pawn_type,
       t.mileage,
       t.buy_money,
       appraiser,
       t.plate_number,
       rank() over(partition by t.u_id order by t.id desc) px
       
       /*,
       t.reg_year||t.reg_month 注册时间,
       t.is_trailer 是否被拖车,
       t.trailer_time 拖车时间,
       trailer_status 拖车状态,
       trailer_sub_status 拖车子状态*/
from ods.u_pbi t
where t.appraisement>0
and u_id<>0
)t
where px=1
 ;
 select count(1),count(distinct t.u_id) from wd_bor_pbi t
 
 ;
 
 
 
 
 
 
 
 