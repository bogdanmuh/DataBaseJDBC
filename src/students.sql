-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1:3306
-- Время создания: Апр 05 2021 г., 03:20
-- Версия сервера: 10.3.13-MariaDB
-- Версия PHP: 7.1.22

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `test_db`
--

-- --------------------------------------------------------

--
-- Структура таблицы `academic_plans`
--

CREATE TABLE `academic_plans` (
  `id` int(11) NOT NULL,
  `year` year(4) NOT NULL,
  `specialization_id` varchar(8) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `cathedras`
--

CREATE TABLE `cathedras` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `disciplines`
--

CREATE TABLE `disciplines` (
  `id` varchar(40) NOT NULL,
  `name` varchar(80) NOT NULL,
  `cathedra_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `disciplines_plans`
--

CREATE TABLE `disciplines_plans` (
  `id` int(11) NOT NULL,
  `academic_plan_id` int(11) NOT NULL,
  `discipline_id` varchar(40) NOT NULL,
  `semester_number` int(11) NOT NULL,
  `hours` int(11) NOT NULL,
  `reporting_form` varchar(12) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `groups`
--

CREATE TABLE `groups` (
  `id` varchar(6) NOT NULL,
  `academic_plan_id` int(11) NOT NULL,
  `qualification` enum('master','bachelor','specialist') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `performance`
--

CREATE TABLE `performance` (
  `student_id` int(11) NOT NULL,
  `disciplines_plan_id` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `attempt` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `specializations`
--

CREATE TABLE `specializations` (
  `id` varchar(8) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `students`
--

CREATE TABLE `students` (
  `id` int(11) NOT NULL,
  `first_name` varchar(40) NOT NULL,
  `last_name` varchar(40) NOT NULL,
  `mid_name` varchar(40) DEFAULT NULL,
  `group_id` varchar(6) NOT NULL,
  `gender` set('М','Ж') NOT NULL,
  `birthday` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `academic_plans`
--
ALTER TABLE `academic_plans`
  ADD PRIMARY KEY (`id`),
  ADD KEY `specialization_id` (`specialization_id`);

--
-- Индексы таблицы `cathedras`
--
ALTER TABLE `cathedras`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `disciplines`
--
ALTER TABLE `disciplines`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cathedra_id` (`cathedra_id`);

--
-- Индексы таблицы `disciplines_plans`
--
ALTER TABLE `disciplines_plans`
  ADD PRIMARY KEY (`id`),
  ADD KEY `academic_plan_id` (`academic_plan_id`),
  ADD KEY `discipline_id` (`discipline_id`);

--
-- Индексы таблицы `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`id`),
  ADD KEY `academic_plan_id` (`academic_plan_id`);

--
-- Индексы таблицы `performance`
--
ALTER TABLE `performance`
  ADD PRIMARY KEY (`student_id`,`disciplines_plan_id`),
  ADD KEY `disciplines_plan_id` (`disciplines_plan_id`),
  ADD KEY `student_id` (`student_id`);

--
-- Индексы таблицы `specializations`
--
ALTER TABLE `specializations`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`last_name`,`first_name`),
  ADD KEY `group_id` (`group_id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `academic_plans`
--
ALTER TABLE `academic_plans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT для таблицы `cathedras`
--
ALTER TABLE `cathedras`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `disciplines_plans`
--
ALTER TABLE `disciplines_plans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `students`
--
ALTER TABLE `students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `academic_plans`
--
ALTER TABLE `academic_plans`
  ADD CONSTRAINT `academic_plans_ibfk_1` FOREIGN KEY (`specialization_id`) REFERENCES `specializations` (`id`) ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `disciplines`
--
ALTER TABLE `disciplines`
  ADD CONSTRAINT `disciplines_ibfk_1` FOREIGN KEY (`cathedra_id`) REFERENCES `cathedras` (`id`) ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `disciplines_plans`
--
ALTER TABLE `disciplines_plans`
  ADD CONSTRAINT `disciplines_plan_ibfk_1` FOREIGN KEY (`academic_plan_id`) REFERENCES `academic_plans` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `disciplines_plan_ibfk_2` FOREIGN KEY (`discipline_id`) REFERENCES `disciplines` (`id`) ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `groups`
--
ALTER TABLE `groups`
  ADD CONSTRAINT `groups_ibfk_1` FOREIGN KEY (`academic_plan_id`) REFERENCES `academic_plans` (`id`) ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `performance`
--
ALTER TABLE `performance`
  ADD CONSTRAINT `performance_ibfk_1` FOREIGN KEY (`disciplines_plan_id`) REFERENCES `disciplines_plans` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `performance_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `students_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
