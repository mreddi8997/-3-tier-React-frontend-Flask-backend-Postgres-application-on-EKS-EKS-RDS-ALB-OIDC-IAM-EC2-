resource "aws_db_instance" "postgredb" {
  allocated_storage    = 10
  max_allocated_storage = 20
  storage_type         = "gp2"
  db_name              = "mydb1"
  engine               = "postgres"
  engine_version       = "14.15"
  instance_class       = "db.t3.micro"
  port                 = 5432
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.mydb_subnet_group.name
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.postgres14"
  skip_final_snapshot  = true
  storage_encrypted     = true
    vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period    = 0
  auto_minor_version_upgrade = true
  deletion_protection        = false
  copy_tags_to_snapshot      = true

  depends_on = [aws_db_subnet_group.mydb_subnet_group, aws_security_group.rds, aws_vpc.main]
}

resource "aws_db_subnet_group" "mydb_subnet_group" {
  name       = "mydb-subnet-group"
  subnet_ids = [aws_subnet.rds_1.id, aws_subnet.rds_2.id]


  tags = {
    Name = "mydb-subnet-group"
    environment = "production"
  }
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  vpc_id      = aws_vpc.main.id
  description = "allow inbound access from the ECS only"

  ingress {
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]

  }
}
