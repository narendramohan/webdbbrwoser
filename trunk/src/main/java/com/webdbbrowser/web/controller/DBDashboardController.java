package com.webdbbrowser.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class DBDashboardController {
	@RequestMapping(value = "/dbbrowser", method = RequestMethod.GET)
	public ModelAndView getPages() {

		ModelAndView model = new ModelAndView("home");
		return model;

	}
}
