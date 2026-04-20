use mca;
create table product12(maker varchar(40) not null,
					   modelno int primary key,
                       type varchar(10) not null check (type in('PC','Laptop','printer')));
                       
insert into product12 (maker, modelno, type)values
('HP', 101, 'PC'),
('Dell', 102, 'Laptop'),
('Canon', 103, 'Printer'),
('Lenovo', 104, 'Laptop'),
('Epson', 105, 'Printer');

select * from product12;

create table PC12( Modelno int primary key,
                   Speed int not null,
                   RAM int not null,
                   HD int not null,
                   CD int not null,
                   Price int not null,
                   Model_No int not null references product12(Modelno));

insert into PC12 (Modelno, Speed, RAM, HD, CD, Price, Model_No)values
(101, 3, 16, 500, 1, 700, 101),
(106, 3, 8, 1000, 1, 600, 101),
(107, 2, 12, 256, 0, 500, 101),
(108, 4, 32, 1000, 1, 1200, 101),
(109, 3, 16, 2000, 1, 800, 101);

select * from PC12;

create table laptop12(L_ModelNO int primary key,
					  Speed int not null,
                      RAM int not null,
                      HD int not null,
                      Price int not null,
                      ModelNO int not null references product12(ModelNO));
                      
insert into laptop12(L_ModelNO, Speed, RAM, HD, Price, ModelNO)values
(102, 2, 8, 512, 750, 102),
(110, 3, 16, 1000, 1200, 102),
(111, 2, 4, 256, 400, 102),
(112, 4, 32, 1000, 1500, 102),
(113, 3, 16, 500, 950, 102);

select *from laptop12;

create table printer12(P_ModelNo int primary key,
                       color varchar(20) not null check (color in ('T','F')),
                       type varchar(20) not null,
                       price int not null,
                       ModelNo int not null references product12(ModelNo));
                       
insert into printer12(P_ModelNo, color, type, price, ModelNo)values
(103, 'T', 'Inkjet', 100, 103),
(114, 'F', 'Laser', 200, 103),
(115, 'T', 'Dot Matrix', 75, 103),
(116, 'F', 'Inkjet', 150, 103),
(117, 'T', 'Laser', 250, 103);

select * from printer12;

select p.maker
from product12 p, printer12 pr
where p.modelNo = pr.ModelNo
AND pr.color = 'T';

select * from laptop12 where speed < any (select speed from pc12);

select * from laptop12 where speed < (select max(speed) from pc12);


DELIMITER ;

CREATE TRIGGER check_hd_insert
BEFORE INSERT ON laptop12
FOR EACH ROW
SET @x = check_hd(NEW.HD);

CREATE TRIGGER check_hd_update
BEFORE UPDATE ON laptop12
FOR EACH ROW
SET @x = check_hd(NEW.HD);

SHOW TRIGGERS;

SHOW create trigger check_hd_insert;

show create trigger check_hd_update;



DELIMITER $$

CREATE TRIGGER check_hd_insert_pc1
BEFORE INSERT ON pc12
FOR EACH ROW
BEGIN
    IF NEW.HD <= 20 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'HD must be > 20';
    END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER check_hd_update_pc1
BEFORE UPDATE ON pc12
FOR EACH ROW
BEGIN
    IF NEW.HD <= 20 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'HD must be > 20';
    END IF;
END$$

DELIMITER ;

DECLARE @p_ModelNO int, @color varchar(20), @type varchar(20), @price int;














